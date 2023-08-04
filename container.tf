#--------------------
# ECR
#--------------------

resource "aws_ecr_repository" "sbcntrBackend" {
  name = "sbcntr-backend-from-tf"
  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_repository" "sbcntrFrontend" {
  name = "sbcntr-frontend-from-tf"
  encryption_configuration {
    encryption_type = "KMS"
  }
}
