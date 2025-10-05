variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "boot_disk_gb" {
  type    = number
  default = 30
}

variable "image_family" {
  type    = string
  default = "ubuntu-2204-lts"
}

variable "image_project" {
  type    = string
  default = "ubuntu-os-cloud"
}
