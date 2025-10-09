output "bastion_public_ip" {
  value = {
    for uid, instance in google_compute_instance.gw :
    uid => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "k8s_public_ip" {
  value = {
    for uid, instance in google_compute_instance.k8s :
    uid => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "obs_public_ip" {
  value = {
    for uid, instance in google_compute_instance.obs :
    uid => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "app_public_ip" {
  value = {
    for uid, instance in google_compute_instance.app :
    uid => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "import_command" {
  value       = ""
  description = "Commande d'import Rancher (placeholder)"
}

output "instance_ip" {
  value       = merge(
    { for uid, instance in google_compute_instance.gw : uid => instance.network_interface[0].access_config[0].nat_ip },
    { for uid, instance in google_compute_instance.k8s : uid => instance.network_interface[0].access_config[0].nat_ip },
    { for uid, instance in google_compute_instance.obs : uid => instance.network_interface[0].access_config[0].nat_ip },
    { for uid, instance in google_compute_instance.app : uid => instance.network_interface[0].access_config[0].nat_ip }
  )
  description = "Adresses IP publiques de toutes les instances"
}
