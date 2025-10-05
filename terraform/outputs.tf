output "bastion_public_ip" {
  value = {
    for uid, instance in google_compute_instance.gw :
    uid => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "k8s_private_ip" {
  value = {
    for uid, instance in google_compute_instance.k8s :
    uid => instance.network_interface[0].network_ip
  }
}

output "obs_private_ip" {
  value = {
    for uid, instance in google_compute_instance.obs :
    uid => instance.network_interface[0].network_ip
  }
}

output "app_private_ip" {
  value = {
    for uid, instance in google_compute_instance.app :
    uid => instance.network_interface[0].network_ip
  }
}

output "import_command" {
  value       = ""
  description = "Commande d'import Rancher (placeholder)"
}

output "instance_ip" {
  value       = { for uid, instance in google_compute_instance.gw : uid => instance.network_interface[0].network_ip }
  description = "Adresses IP internes des instances"
}
