output "s3_bucket_id" {
  description = "The name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for state encryption"
  value       = aws_kms_key.terraform_state.arn
}
