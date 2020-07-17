resource "aws_s3_bucket" "private_bucket" {
  bucket = var.bucket
  acl    = "private"

versioning {
    enabled = true
}

server_side_encryption_configuration {
    rule {
            apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

tags = {
        Name        = "CloudFormation-Private-Bucket"
    }
}

resource "aws_s3_bucket_object" "uploads" {
  bucket = aws_s3_bucket.private_bucket.bucket
  key = "My_Pic.JPG"
  source = "/home/ec2-user/My_Pic.JPG"
  server_side_encryption = "AES256"
}