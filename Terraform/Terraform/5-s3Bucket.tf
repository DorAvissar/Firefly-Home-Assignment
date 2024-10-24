resource "aws_s3_bucket" "firefly_bucket" {
  bucket = "firefly-bucket-${random_string.suffix.result}" # Ensure the bucket name is unique

  tags = {
    Name = "Firefly-S3-Bucket"
  }
}

resource "aws_s3_bucket_versioning" "firefly_versioning" {
  bucket = aws_s3_bucket.firefly_bucket.id

  versioning_configuration {
    status = "Enabled" # Enable versioning for the bucket
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
