resource "aws_security_group" "http_ssh_ec2_website_security_group" {
  name = "http_ssh_ec2_website_security_group"
  description = "http ssh ec2 security group built for the website by terraform"
  vpc_id = aws_vpc.website_fpm_nginx_vpc.id

  ingress {
    description = "http access"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "as proxy"
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.website_fpm_nginx_vpc.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "http_ssh_ec2_website_security_group"
  }
}

resource "aws_security_group" "fpm_ec2_website_security_group" {
  depends_on = [ aws_instance.nginx_ec2_website_instance ]

  name = "fpm_ec2_website_security_group"
  description = "ec2 security group built for the website by terraform"
  vpc_id = aws_vpc.website_fpm_nginx_vpc.id

  ingress {
    description = "http access"
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.nginx_ec2_website_instance.private_ip}/32"]
  }

  ingress {
    description = "ssh access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.nginx_ec2_website_instance.private_ip}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fpm_ec2_website_security_group"
  }
}