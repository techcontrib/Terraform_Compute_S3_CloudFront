data "aws_iam_policy_document" "s3_distribution" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.private_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.s3_distribution.iam_arn}"]
    }
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.private_bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.s3_distribution.iam_arn}"]
    }
  }
}
resource "aws_s3_bucket_policy" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  policy = data.aws_iam_policy_document.s3_distribution.json
}
