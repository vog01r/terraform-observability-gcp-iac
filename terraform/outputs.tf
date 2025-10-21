output "app_ip" {
  description = "Private IP address of App VM"
  value       = google_compute_instance.vm_app.network_interface[0].network_ip
}

output "app_public_ip" {
  description = "Public IP address of App VM"
  value       = google_compute_instance.vm_app.network_interface[0].access_config[0].nat_ip
}

output "zabbix_ip" {
  description = "Private IP address of Zabbix VM"
  value       = google_compute_instance.vm_zabbix.network_interface[0].network_ip
}

output "zabbix_public_ip" {
  description = "Public IP address of Zabbix VM"
  value       = google_compute_instance.vm_zabbix.network_interface[0].access_config[0].nat_ip
}

output "grafana_ip" {
  description = "Private IP address of Grafana VM"
  value       = google_compute_instance.vm_grafana.network_interface[0].network_ip
}

output "grafana_public_ip" {
  description = "Public IP address of Grafana VM"
  value       = google_compute_instance.vm_grafana.network_interface[0].access_config[0].nat_ip
}

output "ssh_user" {
  description = "SSH user for VM access"
  value       = var.ssh_user
}

output "inventory_path" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}

output "zabbix_url" {
  description = "Zabbix Web Interface URL"
  value       = "http://${google_compute_instance.vm_zabbix.network_interface[0].access_config[0].nat_ip}/zabbix"
}

output "grafana_url" {
  description = "Grafana Web Interface URL"
  value       = "http://${google_compute_instance.vm_grafana.network_interface[0].access_config[0].nat_ip}:3000"
}

output "app_url" {
  description = "App Web Interface URL"
  value       = "http://${google_compute_instance.vm_app.network_interface[0].access_config[0].nat_ip}:5000"
}