#--------------------
# Security groups
#--------------------
# セキュリティグループの生成
## インターネット公開のセキュリティグループの生成
resource "aws_security_group" "sbcntrSgIngress" {
  name        = "ingress"
  description = "Security group for ingress"
  vpc_id      = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-sg-ingress-from-TF"
  }
}
resource "aws_security_group_rule" "ingress_http_from_ipv4" {
  security_group_id = aws_security_group.sbcntrSgIngress.id
  description       = "from 0.0.0.0/0:80"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_http_from_ipv6" {
  security_group_id = aws_security_group.sbcntrSgIngress.id
  description       = "from ::/0:80"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.sbcntrSgIngress.id
  description       = "Allow all outbound traffic by default"
  type              = "egress"
  protocol          = "-1"
  to_port           = "-1"
  from_port         = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

## 管理用サーバ向けのセキュリティグループの生成
resource "aws_security_group" "sbcntrSgManagement" {
  name        = "management"
  description = "Security Group of management server"
  vpc_id      = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-sg-management-from-TF"
  }
}

resource "aws_security_group_rule" "managementEgress" {
  security_group_id = aws_security_group.sbcntrSgManagement.id
  description       = "Allow all outbound traffic by default"
  type              = "egress"
  protocol          = "-1"
  to_port           = "-1"
  from_port         = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

## バックエンドコンテナアプリ用セキュリティグループの生成
resource "aws_security_group" "sbcntrSgContainer" {
  name        = "container"
  description = "Security Group of backend app"
  vpc_id      = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-sg-container-from-TF"
  }
}

resource "aws_security_group_rule" "containerEgress" {
  security_group_id = aws_security_group.sbcntrSgContainer.id
  description       = "Allow all outbound traffic by default"
  type              = "egress"
  protocol          = "-1"
  to_port           = "-1"
  from_port         = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

## フロントエンドコンテナアプリ用セキュリティグループの生成
resource "aws_security_group" "sbcntrSgFrontContainer" {
  name        = "front-container"
  description = "Security Group of front container app"
  vpc_id      = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-sg-front-container-from-TF"
  }
}

resource "aws_security_group_rule" "frontContainerEgress" {
  security_group_id = aws_security_group.sbcntrSgFrontContainer.id
  description       = "Allow all outbound traffic by default"
  type              = "egress"
  protocol          = "-1"
  to_port           = "-1"
  from_port         = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

## 内部用ロードバランサ用のセキュリティグループの作成
resource "aws_security_group" "sbcntrSgInternal" {
  name        = "internal"
  description = "Security group for internal load balancer"
  vpc_id      = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-sg-internal-from-TF"
  }
}

resource "aws_security_group_rule" "internalEgress" {
  security_group_id = aws_security_group.sbcntrSgInternal.id
  description       = "Allow all outbound traffic by default"
  type              = "egress"
  protocol          = "-1"
  to_port           = "-1"
  from_port         = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

## DB用セキュリティグループの作成
resource "aws_security_group" "sbcntrSgDb" {
  name        = "database"
  description = "Security Group of database"
  vpc_id      = aws_vpc.sbcntrVpc.id
  tags = {
    Name = "sbcntr-sg-db-from-TF"
  }
}

resource "aws_security_group_rule" "dbEgress" {
  security_group_id = aws_security_group.sbcntrSgDb.id
  # TODO:egressの設定が他のSGとも同一冗長なので共通化した
  description = "Allow all outbound traffic by default"
  type        = "egress"
  protocol    = "-1"
  to_port     = "-1"
  from_port   = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}






