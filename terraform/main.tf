resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "google_compute_instance" "rke2_node" {
  name         = "${var.instance_name}-${random_string.unique_suffix.result}"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20231101"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


resource "rancher2_cluster" "imported_cluster" {
  name = "my-imported-cluster-lot1-pc-gcp-${random_string.unique_suffix.result}"
}

resource "local_file" "terraform_outputs" {
  content = jsonencode({
    import_command = rancher2_cluster.imported_cluster.cluster_registration_token[0].command,
    instance_ip    = google_compute_instance.rke2_node.network_interface[0].access_config[0].nat_ip
  })
  filename = "${path.module}/../ansible/vars/terraform_output.json"
}

