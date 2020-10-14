# Terraform_Compute_S3_CloudFront

Terraform code to implement serving S3 contents using CDN (AWS CloudFront)

a. Create S3 Bucket (Private) and upload static images

b. Create CloudFront Distribution

c. Create / Use SSH key

d. Create Security Group allowing ports 22,80 and 443

e. Launch EC2 instance

f. Create EBS volume

g. Attach EBS volume to VM

h. Pull the code from github and place it to newly mounted EBS volume on DocumentRoot

i. Validate the website access (which is via CloudFront) and validate if your S3 bucket is still private and serving contents securely via CloudFront
