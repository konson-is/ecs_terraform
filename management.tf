#--------------------
# cloud9
#--------------------
resource "aws_cloud9_environment_ec2" "sbcntrDev" {
  instance_type               = "t2.micro"
  name                        = "sbcntr-dev-from-TF"
  automatic_stop_time_minutes = 30
  connection_type             = "CONNECT_SSM"
  subnet_id                   = aws_subnet.sbcntrSubnetPublicManagement1A.id
  description                 = "Cloud9 for application development"
  owner_arn                   = local.arn
  tags = {
    Environment = "Development"
  }
}