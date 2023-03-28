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
  vpc_security_group_ids = [aws_security_group.sgr.id]

  tags = merge(
    var.tags,
    { Name = "${var.env}-docdb" }
  )

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

resource "aws_ssm_parameter" "docdb_url_catalogue" {
  name  = "${var.env}.docdb_url_catalogue"
  type  = "String"
  value = "mongodb://${data.aws_ssm_parameter.docdb-user.value}:${data.aws_ssm_parameter.docdb-pass.value}@dev-docdb.cluster-capdsiq5nfpo.us-east-1.docdb.amazonaws.com:27017/catalogue?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

resource "aws_ssm_parameter" "docdb_endpoint" {
  name  = "${var.env}.docdb_endpoint"
  type  = "String"
  value = aws_docdb_cluster.docdbr.endpoint
}

resource "aws_ssm_parameter" "docdb_url_user" {
  name  = "${var.env}.docdb_url_user"
  type  = "String"
  value = "mongodb://${data.aws_ssm_parameter.docdb-user.value}:${data.aws_ssm_parameter.docdb-pass.value}@dev-docdb.cluster-capdsiq5nfpo.us-east-1.docdb.amazonaws.com:27017/user?tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}

resource "aws_security_group" "sgr" {
  name        = "docdb-${var.env}-sg"
  description = "docdb-${var.env}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "docdb port"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.allow_db_to_subnets
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
      var.tags,
      { Name = "docdb-${var.env}" }
    )
}