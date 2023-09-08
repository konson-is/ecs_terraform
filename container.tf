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
      "secrets" : [
        { "name" : "DB_HOST", "valueFrom" : "${aws_secretsmanager_secret.sbcntr-rds-auth-secret.arn}:host::" },
        { "name" : "DB_NAME", "valueFrom" : "${aws_secretsmanager_secret.sbcntr-rds-auth-secret.arn}:dbname::" },
        { "name" : "DB_USERNAME", "valueFrom" : "${aws_secretsmanager_secret.sbcntr-rds-auth-secret.arn}:username::" },
        { "name" : "DB_PASSWORD", "valueFrom" : "${aws_secretsmanager_secret.sbcntr-rds-auth-secret.arn}:password::" },
      ]
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

# frontend
resource "aws_ecs_task_definition" "sbcntr-frontend-taskdef" {
  family                   = "sbcntr-frontend-def-from-TF"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.sbcntr-ecs-task-execution-role.arn
  container_definitions = jsonencode([
    {
      "name" : "app",
      "image" : "${var.account-id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.sbcntr-frontend.name}:dbv1",
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
      "environment" : [
        { "name" : "SESSION_SECRET_KEY", "value" : "${var.session-secret-key}" },
        { "name" : "APP_SERVICE_HOST", "value" : "http://${aws_lb.sbcntr-alb-internal.dns_name}" },
        { "name" : "NOTIF_SERVICE_HOST", "value" : "http://${aws_lb.sbcntr-alb-internal.dns_name}" }
      ],
      "secrets" : [
        { "name" : "DB_HOST", "valueFrom" : "${aws_secretsmanager_secret.sbcntr-rds-auth-secret.arn}:host::" },
        { "name" : "DB_NAME", "valueFrom" : "${aws_secretsmanager_secret.sbcntr-rds-auth-secret.arn}:dbname::" },
        { "name" : "DB_USERNAME", "valueFrom" : "${aws_secretsmanager_secret.sbcntr-rds-auth-secret.arn}:username::" },
        { "name" : "DB_PASSWORD", "valueFrom" : "${aws_secretsmanager_secret.sbcntr-rds-auth-secret.arn}:password::" },
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/sbcntr-frontend-from-tf-def",
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

# frontend
resource "aws_ecs_cluster" "sbcntr-frontend-cluster" {
  name = "sbcntr-ecs-frontend-cluster-from-TF"

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

# frontend
# 本書にはサービスの設定は無いが、起動し直すごとにALBのターゲットグループにfrontコンテナのIPを設定するのが面倒であるため作成
resource "aws_ecs_service" "sbcntr-ecs-frontend-service" {
  name                               = "sbcntr-ecs-frontend-service"
  cluster                            = aws_ecs_cluster.sbcntr-frontend-cluster.id
  task_definition                    = aws_ecs_task_definition.sbcntr-frontend-taskdef.arn
  launch_type                        = "FARGATE"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = 120
  platform_version                   = "LATEST"



  deployment_controller {
    type = "ECS"
  }
  network_configuration {
    subnets          = [aws_subnet.sbcntr-subnet-private-container-1a.id, aws_subnet.sbcntr-subnet-private-container-1c.id]
    security_groups  = [aws_security_group.sbcntr-sg-front-container.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sbcntr-tg-frontend.arn
    container_name   = jsondecode(aws_ecs_task_definition.sbcntr-frontend-taskdef.container_definitions)[0].name
    container_port   = 80
  }
}
