/* Create/launch Application using Terraform
1. Create S3 Bucket (Private) and upload static images
2. Create CloudFront Distribution
3. Create / Use SSH key
4. Create Security Group allowing ports 22,80 and 443
5. Launch EC2 instance 
6. Create EBS volume
7. Attach EBS volume to VM
8. Pull the code from github and place it to newly mounted EBS volume on DocumentRoot
9. Validate the website access (which is via CloudFront) and validate if your S3 bucket is still private and serving contents securly via CloudFront
*/

provider "aws" {
    region  = var.region
    version = "~> 2.66"
    profile    = "autoid"
}
