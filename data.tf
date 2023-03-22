data "aws_ssm_parameter" "docdb-user" {
  name = "${var.env}.docdb.user"
}

data "aws_ssm_parameter" "docdb-pass" {
  name = "${var.env}.docdb.pass"
}