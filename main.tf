provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}

#--------------------
# VPC
#--------------------
resource "aws_vpc" "sbcntrVpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sbcntrVpc-from-TF"
  }
}

#--------------------
# Subnet,RouteTable,IGW
#--------------------

# IGWの作成
resource "aws_internet_gateway" "sbcntrIgw" {
  vpc_id = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-igw-TF"
  }

}

# コンテナ周りの設定
## コンテナアプリ用のプライベートサブネット

resource "aws_subnet" "sbcntrSubnetPrivateContainer1A" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1a-from-TF"
    Type = "Isolated"
  }
}

resource "aws_subnet" "sbcntrSubnetPrivateContainer1C" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.9.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1c-from-TF"
    Type = "Isolated"
  }

}

## コンテナアプリ用のルートテーブル
resource "aws_route_table" "sbcntrRouteApp" {
  vpc_id = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-route-app-from-TF"
  }
}

## コンテナサブネットへルート紐付け
resource "aws_route_table_association" "sbcntrRouteAppAssociation1A" {
  route_table_id = aws_route_table.sbcntrRouteApp.id
  subnet_id      = aws_subnet.sbcntrSubnetPrivateContainer1A.id
}

resource "aws_route_table_association" "sbcntrRouteAppAssociation1C" {
  route_table_id = aws_route_table.sbcntrRouteApp.id
  subnet_id      = aws_subnet.sbcntrSubnetPrivateContainer1C.id
}

# DB周りの設定
## DB用のプライベートサブネット

resource "aws_subnet" "sbcntrSubnetPrivateDb1A" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.16.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "sbcntr-subnet-private-db-1a-from-TF"
  }

}

resource "aws_subnet" "sbcntrSubnetPrivateDb1C" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.17.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-db-1c-from-TF"
  }

}

## DB用のルートテーブル
resource "aws_route_table" "sbcntrRouteDb" {
  vpc_id = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-route-db-from-TF"
  }
}

## DBサブネットへルート紐付け
resource "aws_route_table_association" "sbcntrRouteDbAssociation1A" {
  route_table_id = aws_route_table.sbcntrRouteDb.id
  subnet_id      = aws_subnet.sbcntrSubnetPrivateDb1A.id
}

resource "aws_route_table_association" "sbcntrRouteDbAssociation1C" {
  route_table_id = aws_route_table.sbcntrRouteDb.id
  subnet_id      = aws_subnet.sbcntrSubnetPrivateDb1C.id
}

# Ingress周りの設定
## Ingress用のパブリックサブネット

resource "aws_subnet" "sbcntrSubnetPublicIngress1A" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1a-from-TF"
  }

}

resource "aws_subnet" "sbcntrSubnetPublicIngress1C" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1c-from-TF"
  }

}

## Ingress用のルートテーブル
resource "aws_route_table" "sbcntrRouteIngress" {
  vpc_id = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-route-ingress-TF"
  }

}

## Ingressサブネットへルート紐付け
resource "aws_route_table_association" "sbcntrRouteIngressAssociation1A" {
  route_table_id = aws_route_table.sbcntrRouteIngress.id
  subnet_id      = aws_subnet.sbcntrSubnetPublicIngress1A.id
}

resource "aws_route_table_association" "sbcntrRouteIngressAssociation1C" {
  route_table_id = aws_route_table.sbcntrRouteIngress.id
  subnet_id      = aws_subnet.sbcntrSubnetPublicIngress1C.id
}

## Ingress用ルートテーブルのデフォルトルート
resource "aws_route" "sbcntrRouteIngressDefault" {
  route_table_id         = aws_route_table.sbcntrRouteIngress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sbcntrIgw.id
}

# Egress周りの設定
## VPCエンドポイント(Egress通信)用のプライベートサブネット

resource "aws_subnet" "sbcntrSubnetPrivateEgress1A" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.248.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-egress-1a-from-TF"
  }

}

resource "aws_subnet" "sbcntrSubnetPrivateEgress1C" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.249.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-egress-1c-from-TF"
  }

}


# 管理用サーバ周りの設定
## 管理用のパブリックサブネット
resource "aws_subnet" "sbcntrSubnetPublicManagement1A" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.240.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1a-from-TF"
  }

}
resource "aws_subnet" "sbcntrSubnetPublicManagement1C" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.241.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1c-from-TF"
  }

}





