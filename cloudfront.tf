// Create CloudFront Distribution
/*CloudFront will have access to the private bucket contents through an origin access identity. 
This doesn’t require any parameters, though you can add a comment if you want.*/

//creating cloudfront origin access identity
resource "aws_cloudfront_origin_access_identity" "s3_distribution" {
  comment = "CloudFront_Origin01"
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_s3_bucket_object.uploads]
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false
/* Setting wait_for_deployment to false means terraform will exit as soon as it’s made all the updates to AWS API objects \
and won’t poll for the distribution to become ready, which can take 15 to 20 minutes; \
you can watch this in the AWS console or with the CLI (aws cloudfront wait). */
  price_class  		  = "PriceClass_All"
  http_version 		  = "http2"

  origin {
    domain_name = aws_s3_bucket.private_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_distribution.cloudfront_access_identity_path
    }
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
   }

  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
    
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

    ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Name    = "cloudfront"
    Contact = "nileshjoshi.aws@gmail.com"
  }
}