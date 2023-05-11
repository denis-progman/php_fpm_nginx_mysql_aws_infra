
variable "host" {
  type    = string
}

variable "user" {
  type    = string
  default = "ec2-user"
}

variable "private_key" {}

variable "file_source" {
  type    = string
  default = ""
}

variable "file_destination" {
  type    = string
  default = ""
}

variable "exec_lines" {
  type    = list(string)
  default = []
}

variable "bastion_host" {
  type    = string
}

variable "bastion_user" {
  type    = string
  default = "ec2-user"
}

variable "bastion_private_key" {}

resource "null_resource" "file_exec_provision" {  
  connection {
    bastion_host = var.bastion_host
    bastion_user = var.bastion_user
    bastion_private_key = var.bastion_private_key
    
    host     = var.host
    type     = "ssh"
    user     = var.user
    private_key = var.private_key
    timeout = "1m"
  }

  provisioner "file" {
    source      = var.file_source
    destination = var.file_destination
  }

  provisioner "remote-exec" {
    inline = var.exec_lines
  }
}