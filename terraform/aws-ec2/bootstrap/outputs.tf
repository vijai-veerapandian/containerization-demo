
output "s3_bucket_name" {
  value = aws_s3_bucket.state_bucket.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_lock_table.name
}
