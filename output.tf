output "tfinstance" {
	value = aws_instance.tfinstance.public_ip
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfrontdomain" {
 value = aws_cloudfront_distribution.s3_distribution.domain_name
}