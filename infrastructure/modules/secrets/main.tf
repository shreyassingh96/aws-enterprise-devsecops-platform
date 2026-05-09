terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-db-creds-${var.environment}"
  description             = "RDS Database credentials"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = 0 # Force delete immediately during destroy
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = 5432
    dbname   = var.db_name
  })
}
