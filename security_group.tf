#--------------------
# Security groups
#--------------------
# セキュリティグループの生成
## インターネット公開のセキュリティグループの生成
resource "aws_security_group" "sbcntr-sg-ingress" {
  name        = "ingress"
  description = "Security group for ingress"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  ingress = [{
    description      = "from 0.0.0.0/0:80"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false

    }, {
    description      = "from ::/0:80"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks      = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
  egress = [var.egress-default-rule]
  tags = {
    Name = "sbcntr-sg-ingress-from-TF"
  }
}


## 管理用サーバ向けのセキュリティグループの生成
resource "aws_security_group" "sbcntr-sg-management" {
  name        = "management"
  description = "Security Group of management server"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  egress      = [var.egress-default-rule]
  tags = {
    Name = "sbcntr-sg-management-from-TF"
  }
}

## バックエンドコンテナアプリ用セキュリティグループの生成
resource "aws_security_group" "sbcntr-sg-container" {
  name        = "container"
  description = "Security Group of backend app"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  ingress = [{
    description      = "from internal lb"
    protocol         = "-1"
    to_port          = 0
    from_port        = 0
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups = [aws_security_group.sbcntr-sg-internal.id]
    self             = false
  }]
  egress      = [var.egress-default-rule]
  tags = {
    Name = "sbcntr-sg-container-from-TF"
  }
}

## フロントエンドコンテナアプリ用セキュリティグループの生成
resource "aws_security_group" "sbcntr-sg-front-container" {
  name        = "front-container"
  description = "Security Group of front container app"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  ingress = [{
    description      = "from ingress lb"
    protocol         = "tcp"
    to_port          = 80
    from_port        = 80
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups = [aws_security_group.sbcntr-sg-ingress.id]
    self             = false
  }]
  egress      = [var.egress-default-rule]
  tags = {
    Name = "sbcntr-sg-front-container-from-TF"
  }
}

## 内部用ロードバランサ用のセキュリティグループの作成
resource "aws_security_group" "sbcntr-sg-internal" {
  name        = "internal"
  description = "Security group for internal load balancer"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  ingress = [{
    description      = "HTTP for management server"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = [aws_security_group.sbcntr-sg-management.id]
    self             = false

    }, {
    description      = "HTTP for front container"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = [aws_security_group.sbcntr-sg-front-container.id]
    self             = false
    }, {
    description      = "Test port for management server"
    protocol         = "tcp"
    from_port        = 10080
    to_port          = 10080
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = [aws_security_group.sbcntr-sg-management.id]
    self             = false

  }]
  egress = [var.egress-default-rule]
  tags = {
    Name = "sbcntr-sg-internal-from-TF"
  }
}

## DB用セキュリティグループの作成
resource "aws_security_group" "sbcntr-sg-db" {
  name        = "database"
  description = "Security Group of database"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  ingress = [{
    description      = "from container and management"
    protocol         = "tcp"
    to_port          = 3306
    from_port        = 3306
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups = [aws_security_group.sbcntr-sg-container.id,aws_security_group.sbcntr-sg-management.id]
    self             = false
  }]
  egress      = [var.egress-default-rule]
  tags = {
    Name = "sbcntr-sg-db-from-TF"
  }
}

## VPCエンドポイント用セキュリティグループの作成
resource "aws_security_group" "sbcntr-sg-egress" {
  name        = "egress"
  description = "Security Group of VPC Endpoint"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  ingress = [{
    description      = "from container"
    protocol         = "tcp"
    to_port          = 443
    from_port        = 443
    cidr_blocks      = [aws_vpc.sbcntr-vpc.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups = [aws_security_group.sbcntr-sg-container.id]
    self             = false
  }]
  egress = [var.egress-default-rule]
  tags = {
    Name = "sbcntr-sg-egress-from-TF"
  }
}






