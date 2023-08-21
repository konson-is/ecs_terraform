#--------------------
# ECR
#--------------------

resource "aws_ecr_repository" "sbcntr-backend" {
  name = "sbcntr-backend-from-tf"
  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_repository" "sbcntr-frontend" {
  name = "sbcntr-frontend-from-tf"
  encryption_configuration {
    encryption_type = "KMS"
  }
}

#--------------------
# task definition
#--------------------

# backend
resource "aws_ecs_task_definition" "sbcntr-backend-taskdef" {
  family = "sbcntr-backend-def-from-TF"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "512"
  memory = "1024"
  execution_role_arn = aws_iam_role.sbcntr-ecs-task-execution-role.arn
  container_definitions = jsonencode([
    {
      "name" : "app",
      "image" : "${var.account-id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.sbcntr-backend.name}:v1",
      "cpu":256,
      "memoryReservation": 512,
      "essential": true,
      "readonlyRootFilesystem":true,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp"
        }
      ],
      "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/sbcntr-backend-fromt-tf-def",
                    "awslogs-region": "${var.region}",
                    "awslogs-stream-prefix": "ecs"
                }
            }
    }
  ])


}
