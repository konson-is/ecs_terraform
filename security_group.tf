#--------------------
# Security groups
#--------------------
# セキュリティグループの生成
## インターネット公開のセキュリティグループの生成
resource "aws_security_group" "sbcntrSgIngress" {
  name        = "ingress"
  description = "Security group for ingress"
  vpc_id      = aws_vpc.sbcntrVpc.id
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
  egress = [var.egressDefaultRule]
  tags = {
    Name = "sbcntr-sg-ingress-from-TF"
  }
}


## 管理用サーバ向けのセキュリティグループの生成
resource "aws_security_group" "sbcntrSgManagement" {
  name        = "management"
  description = "Security Group of management server"
  vpc_id      = aws_vpc.sbcntrVpc.id
  egress      = [var.egressDefaultRule]
  tags = {
    Name = "sbcntr-sg-management-from-TF"
  }
}

## バックエンドコンテナアプリ用セキュリティグループの生成
resource "aws_security_group" "sbcntrSgContainer" {
  name        = "container"
  description = "Security Group of backend app"
  vpc_id      = aws_vpc.sbcntrVpc.id
  egress      = [var.egressDefaultRule]
  tags = {
    Name = "sbcntr-sg-container-from-TF"
  }
}

## フロントエンドコンテナアプリ用セキュリティグループの生成
resource "aws_security_group" "sbcntrSgFrontContainer" {
  name        = "front-container"
  description = "Security Group of front container app"
  vpc_id      = aws_vpc.sbcntrVpc.id
  egress      = [var.egressDefaultRule]
  tags = {
    Name = "sbcntr-sg-front-container-from-TF"
  }
}

## 内部用ロードバランサ用のセキュリティグループの作成
resource "aws_security_group" "sbcntrSgInternal" {
  name        = "internal"
  description = "Security group for internal load balancer"
  vpc_id      = aws_vpc.sbcntrVpc.id
  egress      = [var.egressDefaultRule]
  tags = {
    Name = "sbcntr-sg-internal-from-TF"
  }
}

## DB用セキュリティグループの作成
resource "aws_security_group" "sbcntrSgDb" {
  name        = "database"
  description = "Security Group of database"
  vpc_id      = aws_vpc.sbcntrVpc.id
  egress      = [var.egressDefaultRule]
  tags = {
    Name = "sbcntr-sg-db-from-TF"
  }
}

## VPCエンドポイント用セキュリティグループの作成
resource "aws_security_group" "sbcntrSgEgress" {
  name        = "egress"
  description = "Security Group of VPC Endpoint"
  vpc_id      = aws_vpc.sbcntrVpc.id
  egress      = [var.egressDefaultRule]
  tags = {
    Name = "sbcntr-sg-vpce-from-TF"
  }
}






