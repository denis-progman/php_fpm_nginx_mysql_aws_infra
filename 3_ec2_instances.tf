resource "aws_instance" "nginx_ec2_website_instance" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_website_fpm_nginx_subnet.id
  vpc_security_group_ids =  [aws_security_group.http_ssh_ec2_website_security_group.id]
  key_name = "test-1"
  user_data = file("./scripts/nginx_instance.sh")

  tags = {
      Name = "nginx_ec2_website_instance"
  }
}

resource "aws_instance" "fpm_ec2_website_instance" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.private_website_fpm_nginx_subnet_0.id
    vpc_security_group_ids =  [aws_security_group.fpm_ec2_website_security_group.id]
    key_name = "test-1"
    user_data = file("./scripts/fpm_instance.sh")

  tags = {
      Name = "fpm_ec2_website_instance"
  }
}

module "nginx_file_exec_provision" {
  depends_on = [ aws_instance.nginx_ec2_website_instance ]
  source = "./modules/file_exec_provision"
  host = aws_instance.nginx_ec2_website_instance.public_ip
  private_key = file("~/.ssh/aws_tests/test-1.pem")

  file_source = "./configs/nginx.conf"
  file_destination = "/etc/nginx/nginx.conf"

  exec_lines = [
    "sudo sed -i 's/$FPM_PRIVATE_IP/${aws_instance.fpm_ec2_website_instance.private_ip}/' /etc/nginx/nginx.conf",
    "sudo sed -i 's/$PROXYED_YUM_IP/${aws_instance.fpm_ec2_website_instance.private_ip}/' /etc/nginx/nginx.conf",
    "sudo chmod 755 /etc/nginx/nginx.conf",
    "sudo nginx -s reload",
  ]
}

module "fpm_file_exec_bastion_provision" {
  depends_on = [ aws_instance.fpm_ec2_website_instance, module.nginx_file_exec_provision ]
  source = "./modules/file_exec_provision_bastion"
  bastion_host = aws_instance.nginx_ec2_website_instance.public_ip
  host = aws_instance.fpm_ec2_website_instance.private_ip
  private_key = file("~/.ssh/aws_tests/test-1.pem")
  bastion_private_key = file("~/.ssh/aws_tests/test-1.pem")

  file_source = "./configs/fpm.conf"
  file_destination = "/etc/fpm.conf"

  exec_lines = [
    "sudo chmod 755 /etc/php-fpm.d",
    "sudo systemctl restart php-fpm",
  ]
}

output "private_fpm_ipv4" {
    value = "The private fpm ip: ${aws_instance.fpm_ec2_website_instance.private_ip}"
}

output "public_nginx_address" {
    value = "The public nginx entre: http://${aws_instance.nginx_ec2_website_instance.public_ip}"
}
