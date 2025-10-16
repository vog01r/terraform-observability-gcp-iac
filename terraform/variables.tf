variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "network_cidr" {
  description = "CIDR block for VPC network"
  type        = string
  default     = "10.42.0.0/24"
}

variable "ssh_user" {
  description = "SSH user for VM access"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "app_machine_type" {
  description = "Machine type for App VM"
  type        = string
  default     = "e2-micro"
}

variable "zabbix_machine_type" {
  description = "Machine type for Zabbix VM"
  type        = string
  default     = "e2-standard-2"
}

variable "grafana_machine_type" {
  description = "Machine type for Grafana VM"
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "image_family" {
  description = "Image family for VMs"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "image_project" {
  description = "Image project for VMs"
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    project     = "observability-tp"
    environment = "dev"
    managed_by  = "terraform"
  }
}