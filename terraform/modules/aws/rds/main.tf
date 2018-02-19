resource "aws_db_subnet_group" "db_subnets" {
  name        = "${var.db_name}-${var.tag_environment}-subnets"
  subnet_ids  = ["${var.db_subnets}"]

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}

resource "aws_db_parameter_group" "db_params" {
  name    = "${var.db_name}-${var.tag_environment}-params"
  family  = "postgres9.6"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}

resource "aws_db_instance" "db_instance" {
  name      = "${var.db_name}"
  username  = "${var.db_username}"
  password  = "${var.db_password}"

  engine            = "postgres"
  engine_version    = "9.6.6"
  allocated_storage = 20
  instance_class    = "db.t2.micro"
  storage_type      = "gp2"
  multi_az          = false

  apply_immediately       = true
  db_subnet_group_name    = "${aws_db_subnet_group.db_subnets.name}"
  skip_final_snapshot     = false
  parameter_group_name    = "${aws_db_parameter_group.db_params.name}"
  vpc_security_group_ids  = ["${var.db_secgroups}"]

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}