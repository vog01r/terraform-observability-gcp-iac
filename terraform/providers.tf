provider "google" {
  project     = "level-surfer-473817-p5"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = file("key.json") # Chemin vers le fichier JSON de service
}

terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 1.24.0"
    }
  }
}

provider "rancher2" {
  api_url   = "[URL Rancher]"
  token_key = "[token Rancher]"
  insecure  = true
}