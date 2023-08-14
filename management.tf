#--------------------
# cloud9
#--------------------
resource "aws_cloud9_environment_ec2" "sbcntr-dev" {
  instance_type               = "t2.micro"
  name                        = "sbcntr-dev-from-TF"
  automatic_stop_time_minutes = 30
  connection_type             = "CONNECT_SSH"
  subnet_id                   = aws_subnet.sbcntr-subnet-public-management-1a.id
  description                 = "Cloud9 for application development"
  owner_arn                   = var.arn
  tags = {
    Environment = "Development"
  }
}

# cloud9に使用しているEC2インスタンスを取得
data "aws_instance" "cloud9-instance" {
  filter {
    name = "tag:aws:cloud9:environment"
    values = [
    aws_cloud9_environment_ec2.sbcntr-dev.id]
  }
}

output "cloud9-instance-id" {
  value = data.aws_instance.cloud9-instance.id
}

# cloud9のEC2インスタンスにセキュリティグループをアタッチ
resource "aws_network_interface_sg_attachment" "cloud9-management-sg" {
  security_group_id    = aws_security_group.sbcntr-sg-management.id
  network_interface_id = data.aws_instance.cloud9-instance.network_interface_id
}



