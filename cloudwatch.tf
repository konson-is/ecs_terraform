#--------------------
# ECR
#--------------------

resource "aws_cloudwatch_log_group" "sbcntr-backend-log-group" {
  name = "/ecs/sbcntr-backend-fromt-tf-def"
}