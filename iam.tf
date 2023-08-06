#--------------------
# IAM Policy
#--------------------

# ECR repoの操作
resource "aws_iam_policy" "sbcntr_accessing_ecr_repository_policy" {
  name        = "sbcntr-AccessingECRRepositoryPolicy-from-TF"
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
            "arn:aws:ecr:${var.region}:${var.account_id}:repository/${regex("^.*/(.*)$", aws_ecr_repository.sbcntrBackend.repository_url)[0]}",
            "arn:aws:ecr:${var.region}:${var.account_id}:repository/${regex("^.*/(.*)$", aws_ecr_repository.sbcntrFrontend.repository_url)[0]}",
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
            "arn:aws:ecr:${var.region}:${var.account_id}:repository/${regex("^.*/(.*)$", aws_ecr_repository.sbcntrBackend.repository_url)[0]}",
            "arn:aws:ecr:${var.region}:${var.account_id}:repository/${regex("^.*/(.*)$", aws_ecr_repository.sbcntrFrontend.repository_url)[0]}",
          ]
        }
      ]
    }
  )
}

#--------------------
# policy document
#--------------------

data "aws_iam_policy_document" "ec2_assume_role" {
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
resource "aws_iam_role" "sbcntr_cloud9_role" {
  name               = "sbcntr-cloud9-role-from-TF"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "iam_role_cloud9_policy_attachment" {
  role       = aws_iam_role.sbcntr_cloud9_role.name
  policy_arn = aws_iam_policy.sbcntr_accessing_ecr_repository_policy.arn
}

resource "aws_iam_instance_profile" "cloud9_profile" {
  name = aws_iam_role.sbcntr_cloud9_role.name
  role = aws_iam_role.sbcntr_cloud9_role.name
}

output "sbcntr_cloud9_role_name" {
  value = aws_iam_role.sbcntr_cloud9_role.name
}

