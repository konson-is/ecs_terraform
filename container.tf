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
