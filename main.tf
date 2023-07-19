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
# Subnet(public)
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

# ingress 1c
resource "aws_subnet" "sbcntr-subnet-public-ingress-1c" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "sbcntr-subnet-public-ingress-1c_from_TF"
  }

}

# management 1a
resource "aws_subnet" "sbcntr-subnet-public-management-1a" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.240.0/24"

  tags = {
    Name = "sbcntr-subnet-public-management-1a_from_TF"
  }

}

# management 1c
resource "aws_subnet" "sbcntr-subnet-public-management-1c" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.241.0/24"

  tags = {
    Name = "sbcntr-subnet-public-management-1c_from_TF"
  }

}

#--------------------
# Subnet(private)
#--------------------

# egress 1a
resource "aws_subnet" "sbcntr-subnet-private-egress-1a" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.248.0/24"

  tags = {
    Name = "sbcntr-subnet-private-egress-1a_from_TF"
  }

}

# egress 1c
resource "aws_subnet" "sbcntr-subnet-private-egress-1c" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.249.0/24"

  tags = {
    Name = "sbcntr-subnet-private-egress-1c_from_TF"
  }

}

# db 1a
resource "aws_subnet" "sbcntr-subnet-private-db-1a" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.16.0/24"

  tags = {
    Name = "sbcntr-subnet-private-db-1a_from_TF"
  }

}

# db 1c
resource "aws_subnet" "sbcntr-subnet-private-db-1c" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.17.0/24"

  tags = {
    Name = "sbcntr-subnet-private-db-1c_from_TF"
  }

}

# container 1a
resource "aws_subnet" "sbcntr-subnet-private-container-1a" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.8.0/24"

  tags = {
    Name = "sbcntr-subnet-private-container-1a_from_TF"
  }

}

# container 1c
resource "aws_subnet" "sbcntr-subnet-private-container-1c" {
  vpc_id            = aws_vpc.sbcntrVPC.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.9.0/24"

  tags = {
    Name = "sbcntr-subnet-private-container-1c_from_TF"
  }

}
