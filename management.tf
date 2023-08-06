#--------------------
# cloud9
#--------------------
resource "aws_cloud9_environment_ec2" "sbcntrDev" {
  instance_type               = "t2.micro"
  name                        = "sbcntr-dev-from-TF"
  automatic_stop_time_minutes = 30
  connection_type             = "CONNECT_SSH"
  subnet_id                   = aws_subnet.sbcntrSubnetPublicManagement1A.id
  description                 = "Cloud9 for application development"
  owner_arn                   = var.arn
  tags = {
    Environment = "Development"
  }
}

# cloud9に使用しているEC2インスタンスを取得
data "aws_instance" "cloud9_instance" {
  filter {
    name = "tag:aws:cloud9:environment"
    values = [
    aws_cloud9_environment_ec2.sbcntrDev.id]
  }
}

output "cloud9_instance_id" {
  value = data.aws_instance.cloud9_instance.id
}

# cloud9のEC2インスタンスにセキュリティグループをアタッチ
resource "aws_network_interface_sg_attachment" "cloud9ManagementSg" {
  security_group_id    = aws_security_group.sbcntrSgManagement.id
  network_interface_id = data.aws_instance.cloud9_instance.network_interface_id
}



