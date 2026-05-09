terraform {
  backend "s3" {
    # These values should ideally be passed via terraform init -backend-config
    # or a backend.hcl file for modularity across environments.
    # We define partial configuration here.
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # bucket         = "devsecops-tf-state-dev-<account_id>"
    # dynamodb_table = "devsecops-tf-lock-dev"
  }
}
