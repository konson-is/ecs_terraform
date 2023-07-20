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
# IGW
#--------------------
resource "aws_internet_gateway" "sbcntr-igw" {
  vpc_id = aws_vpc.sbcntrVPC.id
  tags = {
    Name = "sbcntr-igw_TF"
  }

}

resource "aws_route" "ingress_route_igw" {
  route_table_id         = aws_route_table.sbcntr-route-ingress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sbcntr-igw.id
}

#--------------------
# Route Table
#--------------------

resource "aws_route_table" "sbcntr-route-ingress" {
  vpc_id = aws_vpc.sbcntrVPC.id
  tags = {
    Name = "sbcntr-route-ingress_TF"
  }

}

resource "aws_route_table_association" "sbcntr-route-ingres_1a" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-ingress-1a.id
}

resource "aws_route_table_association" "sbcntr-route-ingres_1c" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-ingress-1c.id
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
