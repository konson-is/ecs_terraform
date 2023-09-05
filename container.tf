#--------------------
# ECR
#--------------------

resource "aws_ecr_repository" "sbcntr-backend" {
  name = "sbcntr-backend"
  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_repository" "sbcntr-frontend" {
  name = "sbcntr-frontend"
  encryption_configuration {
    encryption_type = "KMS"
  }
}

#--------------------
# task definition
#--------------------

# backend
resource "aws_ecs_task_definition" "sbcntr-backend-taskdef" {
  family                   = "sbcntr-backend-def-from-TF"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.sbcntr-ecs-task-execution-role.arn
  container_definitions = jsonencode([
    {
      "name" : "app",
      "image" : "${var.account-id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.sbcntr-backend.name}:v1",
      "cpu" : 256,
      "memoryReservation" : 512,
      "essential" : true,
      "readonlyRootFilesystem" : true,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/sbcntr-backend-fromt-tf-def",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

#--------------------
# cluster
#--------------------

# backend
resource "aws_ecs_cluster" "sbcntr-backend-cluster" {
  name = "sbcntr-ecs-backend-cluster-from-TF"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}

#--------------------
# service
#--------------------

# backend
resource "aws_ecs_service" "sbcntr-ecs-backend-service" {
  name                               = "sbcntr-ecs-backend-service"
  cluster                            = aws_ecs_cluster.sbcntr-backend-cluster.id
  task_definition                    = aws_ecs_task_definition.sbcntr-backend-taskdef.arn
  launch_type                        = "FARGATE"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = 120
  platform_version                   = "LATEST"



  deployment_controller {
    type = "CODE_DEPLOY"
  }
  network_configuration {
    subnets          = [aws_subnet.sbcntr-subnet-private-container-1a.id, aws_subnet.sbcntr-subnet-private-container-1c.id]
    security_groups  = [aws_security_group.sbcntr-sg-container.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sbcntr-tg-sbcntrdemo-blue.arn
    container_name   = jsondecode(aws_ecs_task_definition.sbcntr-backend-taskdef.container_definitions)[0].name
    container_port   = 80
  }

  service_registries {
    registry_arn = aws_service_discovery_service.sbcntr-ecs-backend-service.arn

  }
}
