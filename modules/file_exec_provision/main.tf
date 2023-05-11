
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

# variable "depends_on" {
#   type    = list(string)
#   default = []
# }

# locals {
#   depends_on = var.depends_on ? [var.depends_on] : []
# }

resource "null_resource" "file_exec_provision" {  
  # depends_on = [locals.depends_on]
  connection {
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