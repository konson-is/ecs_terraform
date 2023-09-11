#--------------------
# subnet_group
#--------------------
resource "aws_db_subnet_group" "sbcntr-rds-subnet-group" {
  name        = "sbcntr-rds-subnet-group"
  description = "DB subnet group for Aurora"
  subnet_ids  = [aws_subnet.sbcntr-subnet-private-db-1a.id, aws_subnet.sbcntr-subnet-private-db-1c.id]
}

#--------------------
# db instance
#--------------------
resource "aws_rds_cluster" "sbcntr-rds-cluster" {
  cluster_identifier              = "sbcntr-db"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.11.2"
  database_name                   = "sbcntrapp"
  master_username                 = "admin"
  master_password                 = var.db-user-password
  backup_retention_period         = 1
  skip_final_snapshot             = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  storage_encrypted               = true
  deletion_protection             = false
  db_subnet_group_name            = aws_db_subnet_group.sbcntr-rds-subnet-group.name
  vpc_security_group_ids          = [aws_security_group.sbcntr-sg-db.id]
  preferred_maintenance_window    = "Sat:17:00-Sat:17:30"
  apply_immediately               = true
  db_cluster_parameter_group_name = "default.aurora-mysql5.7"
  copy_tags_to_snapshot           = true
  snapshot_identifier             = data.aws_db_cluster_snapshot.sbcntr-db-snapshot.id
}

resource "aws_rds_cluster_instance" "sbcntr-rds-cluster-instance" {
  count                   = 2
  identifier              = "sbcntr-db-instance-${count.index}"
  cluster_identifier      = aws_rds_cluster.sbcntr-rds-cluster.cluster_identifier
  instance_class          = "db.t3.small"
  engine                  = aws_rds_cluster.sbcntr-rds-cluster.engine
  engine_version          = aws_rds_cluster.sbcntr-rds-cluster.engine_version
  db_subnet_group_name    = aws_rds_cluster.sbcntr-rds-cluster.db_subnet_group_name
  db_parameter_group_name = aws_rds_cluster.sbcntr-rds-cluster.db_cluster_parameter_group_name
}

#--------------------
# db snapshot
#--------------------
# スナップショットを用意しておく（Auroraが無料枠外であることから、必要なときだけ同じDB構成で起動できるようにしておくため）
data "aws_db_cluster_snapshot" "sbcntr-db-snapshot" {
  db_cluster_snapshot_identifier = "sbcntr-db-snapshot"
  most_recent                    = true
}
