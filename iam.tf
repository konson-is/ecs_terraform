#--------------------
# IAM Policy
#--------------------

# ECR repoの操作
resource "aws_iam_policy" "sbcntr-accessing-ecr-repository-policy" {
  name        = "sbcntr-accessing-ecr-repository-policy-from-TF"
  description = "Plicy to access ECR repo from Cloud9 instance"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "ListImagesInRepository",
          "Effect" : "Allow",
          "Action" : [
            "ecr:ListImages"
          ],
          "Resource" : [
            "arn:aws:ecr:${var.region}:${var.account-id}:repository/${regex("^.*/(.*)$", aws_ecr_repository.sbcntr-backend.repository_url)[0]}",
            "arn:aws:ecr:${var.region}:${var.account-id}:repository/${regex("^.*/(.*)$", aws_ecr_repository.sbcntr-frontend.repository_url)[0]}",
          ]
        },
        {
          "Sid" : "GetAuthorizationToken",
          "Effect" : "Allow",
          "Action" : [
            "ecr:GetAuthorizationToken"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "ManageRepositoryContents",
          "Effect" : "Allow",
          "Action" : [
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:DescribeImages",
            "ecr:BatchGetImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:PutImage"
          ],
          "Resource" : [
            "arn:aws:ecr:${var.region}:${var.account-id}:repository/${regex("^.*/(.*)$", aws_ecr_repository.sbcntr-backend.repository_url)[0]}",
            "arn:aws:ecr:${var.region}:${var.account-id}:repository/${regex("^.*/(.*)$", aws_ecr_repository.sbcntr-frontend.repository_url)[0]}",
          ]
        }
      ]
    }
  )
}

#--------------------
# policy document
#--------------------

data "aws_iam_policy_document" "ec2-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#--------------------
# IAM Role
#--------------------
## Cloud9のEC2にアタッチするロール
resource "aws_iam_role" "sbcntr-cloud9-role" {
  name               = "sbcntr-cloud9-role-from-TF"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role.json
}

resource "aws_iam_role_policy_attachment" "iam-role-cloud9-policy-attachment" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = aws_iam_policy.sbcntr-accessing-ecr-repository-policy.arn
}

resource "aws_iam_instance_profile" "cloud9-profile" {
  name = aws_iam_role.sbcntr-cloud9-role.name
  role = aws_iam_role.sbcntr-cloud9-role.name
}

output "sbcntr-cloud9-role-name" {
  value = aws_iam_role.sbcntr-cloud9-role.name
}

