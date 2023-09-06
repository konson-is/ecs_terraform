#--------------------
# LogGroup
#--------------------
# backend
resource "aws_cloudwatch_log_group" "sbcntr-backend-log-group" {
  name = "/ecs/sbcntr-backend-fromt-tf-def"
}

# frontend
resource "aws_cloudwatch_log_group" "sbcntr-frontend-log-group" {
  name = "/ecs/sbcntr-frontend-from-tf-def"
  retention_in_days = 14
}