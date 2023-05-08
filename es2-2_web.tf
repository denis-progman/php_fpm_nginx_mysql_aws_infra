terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "teraform-builder"
}

resource "aws_vpc" "website_fpm_nginx_vpc" {
  cidr_block       = "10.0.0.0/22"
  instance_tenancy = "default"
  tags = {
    Name = "website_fpm_nginx_vpc"
  }
}

data "aws_availability_zones" "zones" {
  state = "available"
}

resource "aws_subnet" "private_website_fpm_nginx_subnet_0" {
  availability_zone = data.aws_availability_zones.zones.names[0]
  vpc_id            = aws_vpc.website_fpm_nginx_vpc.id
  cidr_block        = "10.0.0.0/24"
  tags = {
    Name = "private_website_fpm_nginx_sn_0"
  }
}

resource "aws_subnet" "private_website_fpm_nginx_subnet_1" {
  availability_zone = data.aws_availability_zones.zones.names[0]
  vpc_id            = aws_vpc.website_fpm_nginx_vpc.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "private_website_fpm_nginx_sn_1"
  }
}

resource "aws_subnet" "public_website_fpm_nginx_subnet" {
  availability_zone = data.aws_availability_zones.zones.names[0]
  vpc_id            = aws_vpc.website_fpm_nginx_vpc.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true
  
  tags = {
    Name = "public_website_fpm_nginx_sn"
  }
}

resource "aws_internet_gateway" "website_fpm_nginx_gateway" {
  vpc_id = aws_vpc.website_fpm_nginx_vpc.id
}


resource "aws_route_table" "private_website_fpm_nginx_rt" {
  vpc_id = aws_vpc.website_fpm_nginx_vpc.id

  tags = {
    Name = "private_website_fpm_nginx_rt"
  }
}

resource "aws_route_table" "public_website_fpm_nginx_rt" {
  vpc_id = aws_vpc.website_fpm_nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.website_fpm_nginx_gateway.id
  }

  tags = {
    Name = "public_website_fpm_nginx_rt"
  }
}

resource "aws_route_table_association" "private_association_1" {
  route_table_id = aws_route_table.private_website_fpm_nginx_rt.id
  subnet_id      = aws_subnet.private_website_fpm_nginx_subnet_0.id
}

resource "aws_route_table_association" "private_association_2" {
  route_table_id = aws_route_table.private_website_fpm_nginx_rt.id
  subnet_id      = aws_subnet.private_website_fpm_nginx_subnet_1.id
}

resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.public_website_fpm_nginx_rt.id
  subnet_id      = aws_subnet.public_website_fpm_nginx_subnet.id
}


resource "aws_security_group" "ec2_website_security_group" {
  name = "ec2_website_security_group"
  description = "ec2 security group built for the website by terraform"
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

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_website_security_group"
  }
}

data "aws_ami" "amazon_linux"{
    most_recent = true
    owners = ["amazon"]


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

}

resource "aws_instance" "ec2_nginx_website_instance" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.public_website_fpm_nginx_subnet.id
    vpc_security_group_ids =  [aws_security_group.ec2_website_security_group.id]
    key_name = "test-1"
    user_data = file("install_website.sh")

    tags = {
        Name = "ec2_website_instance"
    }
}

# resource "aws_instance" "ec2_nginx_website_instance" {
#     ami = data.aws_ami.amazon_linux.id
#     instance_type = "t3.micro"
#     subnet_id = aws_subnet.private_website_fpm_nginx_subnet_0.id
#     vpc_security_group_ids =  [aws_security_group.ec2_security_group.id]
#     key_name = "test-1"
#     user_data = file("install_website.sh")

#     tags = {
#         Name = "ec2_website_instance"
#     }
# }

output "public_ipv4_address" {
    value = aws_instance.ec2_nginx_website_instance.public_ip
}