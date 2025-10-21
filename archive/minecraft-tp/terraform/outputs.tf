# Outputs pour TP Minecraft - Observabilité

output "minecraft_server_ip" {
  description = "IP publique du serveur Minecraft"
  value       = google_compute_address.minecraft_ip.address
}

output "monitoring_server_ip" {
  description = "IP publique du serveur de monitoring"
  value       = google_compute_address.monitoring_ip.address
}

output "minecraft_server_internal_ip" {
  description = "IP interne du serveur Minecraft"
  value       = google_compute_instance.minecraft_server.network_interface.0.network_ip
}

output "monitoring_server_internal_ip" {
  description = "IP interne du serveur de monitoring"
  value       = google_compute_instance.monitoring_server.network_interface.0.network_ip
}

output "minecraft_server_name" {
  description = "Nom du serveur Minecraft"
  value       = google_compute_instance.minecraft_server.name
}

output "monitoring_server_name" {
  description = "Nom du serveur de monitoring"
  value       = google_compute_instance.monitoring_server.name
}

output "vpc_name" {
  description = "Nom du VPC"
  value       = google_compute_network.minecraft_vpc.name
}

output "subnet_name" {
  description = "Nom du sous-réseau"
  value       = google_compute_subnetwork.minecraft_subnet.name
}

output "ssh_commands" {
  description = "Commandes SSH pour se connecter aux serveurs"
  value = {
    minecraft = "ssh -i ~/.ssh/id_rsa ${var.ssh_user}@${google_compute_address.minecraft_ip.address}"
    monitoring = "ssh -i ~/.ssh/id_rsa ${var.ssh_user}@${google_compute_address.monitoring_ip.address}"
  }
}

output "access_urls" {
  description = "URLs d'accès aux services"
  value = {
    minecraft = "minecraft://${google_compute_address.minecraft_ip.address}:25565"
    prometheus = "http://${google_compute_address.monitoring_ip.address}:9090"
    grafana = "http://${google_compute_address.monitoring_ip.address}:3000 (admin/admin123)"
  }
}
