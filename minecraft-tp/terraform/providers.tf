# Configuration des providers pour TP Minecraft

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configuration du provider Google Cloud
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
