# Copyright 2023 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module "aurora_mysql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.6.2"

  name              = var.database_name
  engine            = "aurora-mysql"
  engine_mode       = "provisioned"
  storage_encrypted = true

  vpc_id                = var.vpc_id
  subnets               = var.database_subnets
  create_security_group = true
  allowed_cidr_blocks   = var.database_subnets_cidr_blocks

  apply_immediately   = true
  skip_final_snapshot = true

  allowed_security_groups = ["${var.cluster_sg_id}"]

  db_parameter_group_name         = aws_db_parameter_group.mysql.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql.id

  instance_class = "db.serverless"
  instances = {
    primary = {}
  }

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 1
  }

  enable_http_endpoint = false
  database_name        = var.database_name

  create_random_password = false
  master_username        = var.db_username
  master_password        = var.db_password
}

resource "aws_db_parameter_group" "mysql" {
  name        = "${var.database_name}-aurora-db-mysql-parameter-group"
  family      = "aurora-mysql8.0"
  description = "${var.database_name}-aurora-db-mysql-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "mysql" {
  name        = "${var.database_name}-aurora-mysql-cluster-parameter-group"
  family      = "aurora-mysql8.0"
  description = "${var.database_name}-aurora-mysql-cluster-parameter-group"
}
