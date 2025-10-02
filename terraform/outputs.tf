output "instance_ip" {
  value = google_compute_instance.rke2_node.network_interface[0].access_config[0].nat_ip
}

output "import_command" {
  value = rancher2_cluster.imported_cluster.cluster_registration_token[0].command
}
