provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}

#--------------------
# VPC
#--------------------
resource "aws_vpc" "sbcntrVPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sbcntrVPC_from_TF"
  }
}

#--------------------
# Subnet
#--------------------

# ingress 1a
resource "aws_subnet" "sbcntr-subnet-public-ingress-1a" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.0.0/24"

  tags = {
    Name = "sbcntr-subnet-public-ingress-1a_from_TF"
  }

}
