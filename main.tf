resource "aws_docdb_cluster" "docdbr" {
  cluster_identifier      = "${var.env}-docdb"
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = data.aws_ssm_parameter.docdb-user
  master_password         = data.aws_ssm_parameter.docdb-pass
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  db_subnet_group_name    = aws.aws_docdb_subnet_group.subnet_id

}

resource "aws_docdb_subnet_group" "subgrpr" {
  name       = "${var.env}-docdb-subnetgroup"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    { Name = "${var.env}-subnet-group" }
  )
}
