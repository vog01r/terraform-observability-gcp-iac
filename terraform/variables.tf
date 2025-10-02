variable "instance_name" {
  default     = "rke2-node"
  description = "Name of the GCE instance"
}

variable "project" {
  default = "[project GCP ID]"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "europe-central2-a"
}
