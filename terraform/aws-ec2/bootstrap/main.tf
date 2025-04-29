provider "aws" {
  region =  var.aws_region
}
 
# create S3 bucket for terraform state
resource "aws_s3_bucket" "state_bucket" {
  bucket = "mytf-state-app-bucket"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "state_bucket_block" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"

# Define the primary key
hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "Bootstrap"
  }
}
