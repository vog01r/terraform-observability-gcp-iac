# Configuration Terraform pour TP Minecraft - Observabilité
# Infrastructure simplifiée avec 2 machines : Minecraft + Monitoring

# Génération d'un ID aléatoire pour éviter les conflits de noms
resource "random_id" "network" {
  byte_length = 4
}

# Création du VPC pour le TP Minecraft
resource "google_compute_network" "minecraft_vpc" {
  name                    = "minecraft-vpc-${random_id.network.hex}"
  auto_create_subnetworks = false
  description             = "VPC pour TP Minecraft - Observabilité"
}

# Création du sous-réseau
resource "google_compute_subnetwork" "minecraft_subnet" {
  name          = "minecraft-subnet-${random_id.network.hex}"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.minecraft_vpc.id
  description   = "Sous-réseau pour TP Minecraft"
}

# Règles de firewall pour le TP Minecraft
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-minecraft-${random_id.network.hex}"
  network = google_compute_network.minecraft_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft-tp"]
  description   = "Autoriser SSH pour TP Minecraft"
}

# Règles de firewall pour Minecraft (port 25565)
resource "google_compute_firewall" "allow_minecraft" {
  name    = "allow-minecraft-${random_id.network.hex}"
  network = google_compute_network.minecraft_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft-server"]
  description   = "Autoriser Minecraft (port 25565)"
}

# Règles de firewall pour Prometheus (port 9090)
resource "google_compute_firewall" "allow_prometheus" {
  name    = "allow-prometheus-${random_id.network.hex}"
  network = google_compute_network.minecraft_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]
  description   = "Autoriser Prometheus (port 9090)"
}

# Règles de firewall pour Grafana (port 3000)
resource "google_compute_firewall" "allow_grafana" {
  name    = "allow-grafana-${random_id.network.hex}"
  network = google_compute_network.minecraft_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]
  description   = "Autoriser Grafana (port 3000)"
}

# Règles de firewall pour communication interne
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-minecraft-${random_id.network.hex}"
  network = google_compute_network.minecraft_vpc.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.1.0/24"]
  target_tags   = ["minecraft-tp"]
  description   = "Communication interne pour TP Minecraft"
}

# Adresses IP publiques pour les machines
resource "google_compute_address" "minecraft_ip" {
  name         = "minecraft-server-ip-${random_id.network.hex}"
  region       = var.region
  description  = "IP publique pour serveur Minecraft"
}

resource "google_compute_address" "monitoring_ip" {
  name         = "monitoring-ip-${random_id.network.hex}"
  region       = var.region
  description  = "IP publique pour serveur de monitoring"
}

# Serveur Minecraft
resource "google_compute_instance" "minecraft_server" {
  name         = "minecraft-server-${random_id.network.hex}"
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true

  tags = ["minecraft-tp", "minecraft-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.minecraft_subnet.id
    access_config {
      nat_ip = google_compute_address.minecraft_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = file("${path.module}/../scripts/install-minecraft-linuxgsm.sh")

  service_account {
    email  = google_service_account.minecraft_sa.email
    scopes = ["cloud-platform"]
  }
}

# Serveur de Monitoring (Prometheus + Grafana)
resource "google_compute_instance" "monitoring_server" {
  name         = "monitoring-server-${random_id.network.hex}"
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true

  tags = ["minecraft-tp", "monitoring"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.minecraft_subnet.id
    access_config {
      nat_ip = google_compute_address.monitoring_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = file("${path.module}/../scripts/install-monitoring.sh")

  service_account {
    email  = google_service_account.monitoring_sa.email
    scopes = ["cloud-platform"]
  }
}

# Service Account pour le serveur Minecraft
resource "google_service_account" "minecraft_sa" {
  account_id   = "minecraft-sa-${random_id.network.hex}"
  display_name = "Service Account pour serveur Minecraft"
  description  = "Service Account pour TP Minecraft"
}

# Service Account pour le serveur de monitoring
resource "google_service_account" "monitoring_sa" {
  account_id   = "monitoring-sa-${random_id.network.hex}"
  display_name = "Service Account pour monitoring"
  description  = "Service Account pour TP Monitoring"
}
