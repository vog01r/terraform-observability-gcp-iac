# Configuration Terraform pour TP Minecraft - Observabilité
# Infrastructure simplifiée avec 2 machines : Minecraft + Monitoring

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

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail
    
    # Mise à jour du système
    apt-get update
    apt-get upgrade -y
    
    # Installation des dépendances
    apt-get install -y openjdk-17-jdk wget curl
    
    # Création du répertoire Minecraft
    mkdir -p /opt/minecraft
    cd /opt/minecraft
    
    # Téléchargement du serveur Minecraft (version Paper pour de meilleures performances)
    wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/1300/downloads/paper-1.20.4-1300.jar
    
    # Création du script de démarrage
    cat > start.sh << 'EOF'
#!/bin/bash
cd /opt/minecraft
java -Xmx2G -Xms1G -jar paper.jar nogui
EOF
    
    chmod +x start.sh
    
    # Création du service systemd
    cat > /etc/systemd/system/minecraft.service << 'EOF'
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/minecraft
ExecStart=/opt/minecraft/start.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable minecraft.service
    
    # Installation de Node Exporter pour les métriques système
    wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
    tar xzf node_exporter-1.6.1.linux-amd64.tar.gz
    mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
    rm -rf node_exporter-1.6.1.linux-amd64*
    
    # Création du service Node Exporter
    cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable node_exporter.service
    systemctl start node_exporter.service
    
    echo "Serveur Minecraft configuré avec Node Exporter"
  EOT

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

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail
    
    # Mise à jour du système
    apt-get update
    apt-get upgrade -y
    
    # Installation des dépendances
    apt-get install -y wget curl
    
    # Installation de Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker ubuntu
    
    # Installation de Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Création du répertoire de configuration
    mkdir -p /opt/monitoring/{prometheus,grafana}
    
    # Configuration Prometheus
    cat > /opt/monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'minecraft-server'
    static_configs:
      - targets: ['${google_compute_instance.minecraft_server.network_interface.0.network_ip}:9100']
    scrape_interval: 10s
    metrics_path: /metrics
EOF
    
    # Configuration Docker Compose
    cat > /opt/monitoring/docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana-storage:/var/lib/grafana
    restart: unless-stopped

volumes:
  grafana-storage:
EOF
    
    # Démarrage des services
    cd /opt/monitoring
    docker-compose up -d
    
    echo "Serveur de monitoring configuré avec Prometheus et Grafana"
  EOT

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
