#--------------------
# secrets manager
#--------------------
resource "aws_secretsmanager_secret" "sbcntr-rds-auth-secret" {
  name        = "sbcntr/mysql"
  description = "コンテナユーザ用sbcntr-dbアクセスのシークレット"
}

resource "aws_secretsmanager_secret_version" "sbcntr-rds-auth-secret-version" {
  secret_id = aws_secretsmanager_secret.sbcntr-rds-auth-secret.id
  secret_string = jsonencode({
    "username" : "sbcntruser",
    "password" : "${var.db-user-password}",
    "engine" : "mysql",
    "host" : "${aws_rds_cluster.sbcntr-rds-cluster.endpoint}"
    "port" : 3306,
    "dbClusterIdentifier" : "${aws_rds_cluster.sbcntr-rds-cluster.cluster_identifier}"
    "dbname" : "${aws_rds_cluster.sbcntr-rds-cluster.database_name}"
  })

}
