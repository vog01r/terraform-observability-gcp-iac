provider "google" {
  project     = "level-surfer-473817-p5"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = file("${path.module}/../key.json")
}

provider "random" {}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}