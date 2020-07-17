// Create Security Group in Default VPC
resource "aws_security_group" "sg_cloudfront" {
  name   = "sg_us_cloudfront"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-us-cloudfront"
  }
}

// Find the latest AMI
data "aws_ami" "centos_latest" {
owners      = ["679593333241"]
most_recent = true

  filter {
      name   = "name"
      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}

//SSH key 
/* Create SSH key on your local system and store the pub and private key under your workspace 
openssl genrsa -out mykey.pem 4096
openssl rsa -in mykey.pem -outform PEM -pubout -out public.pem
REF: https://developers.yubico.com/PIV/Guides/Generating_keys_using_OpenSSL.html
*/
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("mykey.pub")
}

// Launch Instance 
resource "aws_instance" "tfinstance" {
  ami                           = data.aws_ami.centos_latest.id
  instance_type                 = "t2.micro"
  key_name                      = aws_key_pair.mykey.key_name
  security_groups               = [ aws_security_group.sg_cloudfront.name ]
  associate_public_ip_address   = true
  source_dest_check             = false


  tags = {
    Name = "tf-made01.foo.com"
  }
}

// Create and attach EBS volume to EC2 instance
resource "aws_ebs_volume" "ebs01" {
	availability_zone = aws_instance.tfinstance.availability_zone
	size = 1
	
 tags = {
	Name = "TF_derivedEBS"
 }
}

resource "aws_volume_attachment" "ebs_att" {
	device_name = "/dev/sdd"
	volume_id = aws_ebs_volume.ebs01.id
	instance_id = aws_instance.tfinstance.id
	force_detach = true
}

resource "null_resource" "nullremote" {
	depends_on = [ 
		aws_volume_attachment.ebs_att
	]

connection {
	type	= "ssh"
	user	= "centos"
	private_key = file("/home/ec2-user/test_wksp/mykey.pem")
	host	= aws_instance.tfinstance.public_ip
}

provisioner "remote-exec" {
	inline = [
		"sudo yum install httpd php git -y",
		"sudo systemctl restart httpd",
		"sudo systemctl enable httpd",
		"sudo mkfs.ext4 /dev/xvdd",
		"sudo mount /dev/xvdd /var/www/html",
    "sudo setenforce 0",
    "sudo perl -npe 's/SELINUX=enforcing/SELINUX=permissive/g' -i /etc/sysconfig/selinux",
    "sudo chmod -R g+w /var/www/html",
    "sudo chmod g+s /var/www/html",
		"sudo rm -rf /var/www/html/*",
		"sudo git clone https://github.com/techcontrib/TESTHTMLPAGE.git /var/www/html/"
		]
	}
}