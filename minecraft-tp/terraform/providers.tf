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
  project     = "level-surfer-473817-p5"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = file("${path.module}/../../key.json")
}