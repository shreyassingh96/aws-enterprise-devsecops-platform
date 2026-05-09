terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0.0"

  identifier = "${var.project_name}-db-${var.environment}"

  engine               = "postgres"
  engine_version       = "15"
  family               = "postgres15" # DB parameter group
  major_engine_version = "15"         # DB option group

  instance_class = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result
  port     = 5432

  manage_master_user_password = false

  multi_az               = var.environment == "prod" ? true : false
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = var.environment == "prod" ? 7 : 1

  tags = var.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg-${var.environment}"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
  }

  tags = var.tags
}
