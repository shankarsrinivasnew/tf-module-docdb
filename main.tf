resource "aws_docdb_cluster" "docdbr" {
  cluster_identifier      = "${var.env}-docdb"
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = data.aws_ssm_parameter.docdb-user.value
  master_password         = data.aws_ssm_parameter.docdb-pass.value
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  db_subnet_group_name    = aws_docdb_subnet_group.subgrpr.name
  kms_key_id              = data.aws_kms_key.mykey.arn
  storage_encrypted       = var.storage_encrypted

}

resource "aws_docdb_subnet_group" "subgrpr" {
  name       = "${var.env}-docdb-subnetgroup"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    { Name = "${var.env}-subnet-group" }
  )
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count
  identifier         = "${var.env}-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdbr.id
  instance_class     = var.instance_class
}