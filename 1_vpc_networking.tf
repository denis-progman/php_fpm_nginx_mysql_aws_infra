resource "aws_vpc" "website_fpm_nginx_vpc" {
  cidr_block       = "10.0.0.0/22"
  instance_tenancy = "default"
  tags = {
    Name = "website_fpm_nginx_vpc"
  }
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