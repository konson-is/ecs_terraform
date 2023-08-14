#--------------------
# VPC
#--------------------
resource "aws_vpc" "sbcntr-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sbcntr-vpc-from-TF"
  }
}

#--------------------
# Subnet,RouteTable,IGW
#--------------------

# IGWの作成
resource "aws_internet_gateway" "sbcntr-igw" {
  vpc_id = aws_vpc.sbcntr-vpc.id
  tags = {
    Name = "sbcntr-igw-TF"
  }

}

# コンテナ周りの設定
## コンテナアプリ用のプライベートサブネット

resource "aws_subnet" "sbcntr-subnet-private-container-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1a-from-TF"
    Type = "Isolated"
  }
}

resource "aws_subnet" "sbcntr-subnet-private-container-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.9.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1c-from-TF"
    Type = "Isolated"
  }

}

## コンテナアプリ用のルートテーブル
resource "aws_route_table" "sbcntr-route-app" {
  vpc_id = aws_vpc.sbcntr-vpc.id
  tags = {
    Name = "sbcntr-route-app-from-TF"
  }
}

## コンテナサブネットへルート紐付け
resource "aws_route_table_association" "sbcntr-route-app-association-1a" {
  route_table_id = aws_route_table.sbcntr-route-app.id
  subnet_id      = aws_subnet.sbcntr-subnet-private-container-1a.id
}

resource "aws_route_table_association" "sbcntr-route-app-association-1c" {
  route_table_id = aws_route_table.sbcntr-route-app.id
  subnet_id      = aws_subnet.sbcntr-subnet-private-container-1c.id
}

# DB周りの設定
## DB用のプライベートサブネット

resource "aws_subnet" "sbcntr-subnet-private-db-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.16.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "sbcntr-subnet-private-db-1a-from-TF"
  }

}

resource "aws_subnet" "sbcntr-subnet-private-db-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.17.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-db-1c-from-TF"
  }

}

## DB用のルートテーブル
resource "aws_route_table" "sbcntr-route-db" {
  vpc_id = aws_vpc.sbcntr-vpc.id
  tags = {
    Name = "sbcntr-route-db-from-TF"
  }
}

## DBサブネットへルート紐付け
resource "aws_route_table_association" "sbcntr-route-db-association-1a" {
  route_table_id = aws_route_table.sbcntr-route-db.id
  subnet_id      = aws_subnet.sbcntr-subnet-private-db-1a.id
}

resource "aws_route_table_association" "sbcntr-route-db-association-1c" {
  route_table_id = aws_route_table.sbcntr-route-db.id
  subnet_id      = aws_subnet.sbcntr-subnet-private-db-1c.id
}

# Ingress周りの設定
## Ingress用のパブリックサブネット

resource "aws_subnet" "sbcntr-subnet-public-ingress-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1a-from-TF"
  }

}

resource "aws_subnet" "sbcntr-subnet-public-ingress-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1c-from-TF"
  }

}

## Ingress用のルートテーブル
resource "aws_route_table" "sbcntr-route-ingress" {
  vpc_id = aws_vpc.sbcntr-vpc.id
  tags = {
    Name = "sbcntr-route-ingress-TF"
  }

}

## Ingressサブネットへルート紐付け
resource "aws_route_table_association" "sbcntr-route-ingress-association-1a" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-ingress-1a.id
}

resource "aws_route_table_association" "sbcntr-route-ingress-association-1c" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-ingress-1c.id
}

## Ingress用ルートテーブルのデフォルトルート
resource "aws_route" "sbcntr-route-ingress-default" {
  route_table_id         = aws_route_table.sbcntr-route-ingress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sbcntr-igw.id
}

# Egress周りの設定
## VPCエンドポイント(Egress通信)用のプライベートサブネット

resource "aws_subnet" "sbcntr-subnet-private-egress-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.248.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-egress-1a-from-TF"
  }

}

resource "aws_subnet" "sbcntr-subnet-private-egress-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.249.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-egress-1c-from-TF"
  }

}


# 管理用サーバ周りの設定
## 管理用のパブリックサブネット
resource "aws_subnet" "sbcntr-subnet-public-management-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.240.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1a-from-TF"
  }

}
resource "aws_subnet" "sbcntr-subnet-public-management-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.241.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1c-from-TF"
  }

}

## ルートテーブルの紐付け
resource "aws_route_table_association" "sbcntr-route-management-association-1a" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-management-1a.id
}

resource "aws_route_table_association" "sbcntr-route-management-association-1c" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-management-1c.id
}

#--------------------
# VPCエンドポイント
# WARNING:インターフェイス型のエンドポイントは料金がかかるので、使用しない時はコメントアウトして構成から削除しておく
#--------------------
## S3ゲートウェイ
resource "aws_vpc_endpoint" "sbcntr-vpce-s3" {
  vpc_id            = aws_vpc.sbcntr-vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.sbcntr-route-app.id]
  tags = {
    Name = "sbcntr-vpce-s3-from-TF"
  }
}

## ECR API エンドポイント
# resource "aws_vpc_endpoint" "sbcntr-vpce-ecr-api" {
#   vpc_id              = aws_vpc.sbcntr-vpc.id
#   service_name        = "com.amazonaws.${var.region}.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = [aws_subnet.sbcntr-subnet-private-egress-1a.id, aws_subnet.sbcntr-subnet-private-egress-1c.id]
#   private_dns_enabled = true
#   security_group_ids  = [aws_security_group.sbcntr-sg-egress.id]
#   tags = {
#     Name = "sbcntr-vpce-ecr-api-from-TF"
#   }
# }

## ECR DockerClient エンドポイント
# resource "aws_vpc_endpoint" "sbcntr-vpce-ecr-docker" {
#   vpc_id              = aws_vpc.sbcntr-vpc.id
#   service_name        = "com.amazonaws.${var.region}.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = [aws_subnet.sbcntr-subnet-private-egress-1a.id, aws_subnet.sbcntr-subnet-private-egress-1c.id]
#   private_dns_enabled = true
#   security_group_ids  = [aws_security_group.sbcntr-sg-egress.id]
#   tags = {
#     Name = "sbcntr-vpce-ecr-dkr-from-TF"
#   }
# }

## cloudwatch エンドポイント
# resource "aws_vpc_endpoint" "sbcntr-vpce-logs" {
#   vpc_id              = aws_vpc.sbcntr-vpc.id
#   service_name        = "com.amazonaws.${var.region}.logs"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = [aws_subnet.sbcntr-subnet-private-egress-1a.id, aws_subnet.sbcntr-subnet-private-egress-1c.id]
#   private_dns_enabled = true
#   security_group_ids  = [aws_security_group.sbcntr-sg-egress.id]
#   tags = {
#     Name = "sbcntr-vpce-logs-from-TF"
#   }
# }



