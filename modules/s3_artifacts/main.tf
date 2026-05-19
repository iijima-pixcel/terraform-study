resource "aws_s3_bucket" "ansible_artifacts" {
  bucket = var.ansible_artifacts_bucket_name

  tags = {
    Name = var.ansible_artifacts_bucket_name
  }
}

resource "aws_s3_bucket_versioning" "ansible_artifacts" {
  bucket = aws_s3_bucket.ansible_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ansible_artifacts" {
  bucket = aws_s3_bucket.ansible_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ansible_artifacts" {
  bucket = aws_s3_bucket.ansible_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
