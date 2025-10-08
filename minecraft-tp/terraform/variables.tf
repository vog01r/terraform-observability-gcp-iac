# Variables pour TP Minecraft - Observabilité

variable "project_id" {
  description = "ID du projet Google Cloud"
  type        = string
}

variable "region" {
  description = "Région Google Cloud"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone Google Cloud"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "Type de machine pour les instances"
  type        = string
  default     = "e2-standard-2"
}

variable "ssh_user" {
  description = "Utilisateur SSH"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
