# VPC Network
resource "google_compute_network" "observability_vpc" {
  name                    = "observability-vpc"
  auto_create_subnetworks = false
  description             = "VPC for observability TP"
}

# Subnet
resource "google_compute_subnetwork" "observability_subnet" {
  name          = "observability-subnet"
  ip_cidr_range = var.network_cidr
  region        = var.region
  network       = google_compute_network.observability_vpc.id
}

# Firewall Rules
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.observability_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # TODO: Restreindre aux IPs admin
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.observability_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}

resource "google_compute_firewall" "allow_grafana" {
  name    = "allow-grafana"
  network = google_compute_network.observability_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["grafana"]
}

resource "google_compute_firewall" "allow_zabbix_agent" {
  name    = "allow-zabbix-agent"
  network = google_compute_network.observability_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10050"]
  }

  source_ranges = [var.network_cidr]
  target_tags   = ["zabbix-agent"]
}

resource "google_compute_firewall" "allow_zabbix_server" {
  name    = "allow-zabbix-server"
  network = google_compute_network.observability_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10051"]
  }

  source_ranges = [var.network_cidr]
  target_tags   = ["zabbix-server"]
}

# SSH Key
data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

# App VM
resource "google_compute_instance" "vm_app" {
  name         = "vm-app"
  machine_type = var.app_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = google_compute_network.observability_vpc.id
    subnetwork = google_compute_subnetwork.observability_subnet.id
    
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${data.local_file.ssh_public_key.content}"
  }

  tags = ["ssh", "http", "zabbix-agent"]
  
  labels = merge(var.labels, {
    role = "app"
  })

  allow_stopping_for_update = true
}

# Zabbix VM
resource "google_compute_instance" "vm_zabbix" {
  name         = "vm-zabbix"
  machine_type = var.zabbix_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = google_compute_network.observability_vpc.id
    subnetwork = google_compute_subnetwork.observability_subnet.id
    
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${data.local_file.ssh_public_key.content}"
  }

  tags = ["ssh", "http", "zabbix-server"]
  
  labels = merge(var.labels, {
    role = "zabbix"
  })

  allow_stopping_for_update = true
}

# Grafana VM
resource "google_compute_instance" "vm_grafana" {
  name         = "vm-grafana"
  machine_type = var.grafana_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = google_compute_network.observability_vpc.id
    subnetwork = google_compute_subnetwork.observability_subnet.id
    
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${data.local_file.ssh_public_key.content}"
  }

  tags = ["ssh", "grafana"]
  
  labels = merge(var.labels, {
    role = "grafana"
  })

  allow_stopping_for_update = true
}

# Generate Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.ini.tmpl", {
    app_ip   = google_compute_instance.vm_app.network_interface[0].network_ip
    zbx_ip   = google_compute_instance.vm_zabbix.network_interface[0].network_ip
    graf_ip  = google_compute_instance.vm_grafana.network_interface[0].network_ip
    ssh_user = var.ssh_user
  })
  filename = "${path.module}/../ansible/inventory/inventory.ini"
}