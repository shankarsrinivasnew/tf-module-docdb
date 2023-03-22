resource "aws_docdb_cluster" "docdbr" {
  cluster_identifier      = "${var.env}-docdb"
  engine                  = var.engine
  master_username         = data.aws_ssm_parameter.docdb-user
  master_password         = data.aws_ssm_parameter.docdb-pass
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
}

resource "aws_docdb_subnet_group" "subgrpr" {
  name       = "${var.env}-docdb-subnetgroup"
  subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]

  tags = {
    Name = "My docdb subnet group"
  }
}