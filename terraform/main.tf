resource "random_pet" "uid" {
  length = 1
}

resource "random_id" "network" {
  byte_length = 2
}

locals {
  uid = format("std-%s", random_pet.uid.id)

  students = {
    main = {
      uid = local.uid
    }
  }

  network_name = format("vpc-%s", random_id.network.hex)
  subnet_name  = format("subnet-%s", random_id.network.hex)
  primary_key  = one(keys(local.students))
}

resource "google_compute_network" "observa_vpc" {
  name                    = local.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "observa_subnet" {
  name          = local.subnet_name
  ip_cidr_range = "192.168.10.0/24"
  region        = "us-central1"
  network       = google_compute_network.observa_vpc.id
}

# Règle firewall pour autoriser SSH sur toutes les VMs
resource "google_compute_firewall" "allow_ssh_all" {
  name    = format("allow-ssh-all-%s", random_id.network.hex)
  network = google_compute_network.observa_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  # Pas de target_tags = autorise SSH sur toutes les VMs
}

# Route par défaut supprimée - chaque VM aura sa propre IP publique

resource "google_compute_address" "ext_ip" {
  for_each     = local.students
  name         = format("ext-ip-%s", local.students[each.key].uid)
  region       = "us-central1"
  address_type = "EXTERNAL"
}

# IPs publiques pour toutes les VMs
resource "google_compute_address" "ext_ip_k8s" {
  for_each     = local.students
  name         = format("ext-ip-k8s-%s", local.students[each.key].uid)
  region       = "us-central1"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "ext_ip_obs" {
  for_each     = local.students
  name         = format("ext-ip-obs-%s", local.students[each.key].uid)
  region       = "us-central1"
  address_type = "EXTERNAL"
}

resource "google_compute_address" "ext_ip_app" {
  for_each     = local.students
  name         = format("ext-ip-app-%s", local.students[each.key].uid)
  region       = "us-central1"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "gw" {
  for_each     = local.students
  name         = format("%s-gw", local.students[each.key].uid)
  machine_type = var.machine_type
  zone         = "us-central1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size  = var.boot_disk_gb
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.observa_subnet.id
    network_ip = "192.168.10.253"

    access_config {
      nat_ip = google_compute_address.ext_ip[each.key].address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  # Plus de configuration NAT - chaque VM a sa propre IP publique
}

resource "google_compute_instance" "k8s" {
  for_each     = local.students
  name         = format("%s-k8s", local.students[each.key].uid)
  machine_type = var.machine_type
  zone         = "us-central1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size  = var.boot_disk_gb
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.observa_subnet.id
    access_config {
      nat_ip = google_compute_address.ext_ip_k8s[each.key].address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

resource "google_compute_instance" "obs" {
  for_each     = local.students
  name         = format("%s-obs", local.students[each.key].uid)
  machine_type = var.machine_type
  zone         = "us-central1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size  = var.boot_disk_gb
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.observa_subnet.id
    access_config {
      nat_ip = google_compute_address.ext_ip_obs[each.key].address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

resource "google_compute_instance" "app" {
  for_each     = local.students
  name         = format("%s-app", local.students[each.key].uid)
  machine_type = var.machine_type
  zone         = "us-central1-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size  = var.boot_disk_gb
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.observa_subnet.id
    access_config {
      nat_ip = google_compute_address.ext_ip_app[each.key].address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile(
    "${path.module}/../ansible/templates/inventory.ini.tftpl",
    {
      students           = local.students
      bastion_public_ip  = { for uid, instance in google_compute_instance.gw : uid => instance.network_interface[0].access_config[0].nat_ip }
      k8s_public_ip      = { for uid, instance in google_compute_instance.k8s : uid => instance.network_interface[0].access_config[0].nat_ip }
      obs_public_ip      = { for uid, instance in google_compute_instance.obs : uid => instance.network_interface[0].access_config[0].nat_ip }
      app_public_ip      = { for uid, instance in google_compute_instance.app : uid => instance.network_interface[0].access_config[0].nat_ip }
    }
  )

  filename = "${path.module}/../ansible/inventory/generated.ini"

  depends_on = [
    google_compute_instance.gw,
    google_compute_instance.k8s,
    google_compute_instance.obs,
    google_compute_instance.app
  ]
}

resource "local_file" "terraform_outputs_json" {
  content = jsonencode({
    bastion_public_ip = google_compute_instance.gw[local.primary_key].network_interface[0].access_config[0].nat_ip
    k8s_public_ip     = google_compute_instance.k8s[local.primary_key].network_interface[0].access_config[0].nat_ip
    obs_public_ip     = google_compute_instance.obs[local.primary_key].network_interface[0].access_config[0].nat_ip
    app_public_ip     = google_compute_instance.app[local.primary_key].network_interface[0].access_config[0].nat_ip
    instance_ip       = merge(
      { for key, instance in google_compute_instance.gw : "${key}-gw" => instance.network_interface[0].access_config[0].nat_ip },
      { for key, instance in google_compute_instance.k8s : "${key}-k8s" => instance.network_interface[0].access_config[0].nat_ip },
      { for key, instance in google_compute_instance.obs : "${key}-obs" => instance.network_interface[0].access_config[0].nat_ip },
      { for key, instance in google_compute_instance.app : "${key}-app" => instance.network_interface[0].access_config[0].nat_ip }
    )
    import_command    = ""
    network_name      = local.network_name
    subnet_name       = local.subnet_name
  })

  filename = "${path.module}/../ansible/vars/terraform_output.json"

  depends_on = [
    google_compute_instance.gw,
    google_compute_instance.k8s,
    google_compute_instance.obs,
    google_compute_instance.app
  ]
}

output "network_name" {
  value = local.network_name
}

output "subnet_name" {
  value = local.subnet_name
}

