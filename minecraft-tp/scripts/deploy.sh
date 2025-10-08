#!/bin/bash

# Script de déploiement pour TP Minecraft - Observabilité
# Ce script automatise le déploiement complet de l'infrastructure

set -euo pipefail

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Terraform
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform n'est pas installé"
        exit 1
    fi
    
    # Vérifier Ansible
    if ! command -v ansible &> /dev/null; then
        log_error "Ansible n'est pas installé"
        exit 1
    fi
    
    # Vérifier la clé SSH
    if [ ! -f ~/.ssh/id_rsa ]; then
        log_error "Clé SSH privée non trouvée (~/.ssh/id_rsa)"
        exit 1
    fi
    
    # Vérifier le fichier de configuration
    if [ ! -f terraform/terraform.tfvars ]; then
        log_error "Fichier terraform.tfvars non trouvé"
        log_info "Copiez terraform.tfvars.example vers terraform.tfvars et configurez-le"
        exit 1
    fi
    
    log_success "Tous les prérequis sont satisfaits"
}

# Déploiement Terraform
deploy_terraform() {
    log_info "Déploiement de l'infrastructure Terraform..."
    
    cd terraform
    
    # Initialisation
    log_info "Initialisation de Terraform..."
    terraform init
    
    # Planification
    log_info "Planification du déploiement..."
    terraform plan
    
    # Confirmation
    read -p "Voulez-vous continuer avec le déploiement ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Déploiement annulé"
        exit 0
    fi
    
    # Déploiement
    log_info "Déploiement en cours..."
    terraform apply -auto-approve
    
    # Sauvegarde des outputs
    log_info "Sauvegarde des outputs Terraform..."
    terraform output -json > ../ansible/terraform_outputs.json
    
    cd ..
    log_success "Déploiement Terraform terminé"
}

# Génération de l'inventaire Ansible
generate_ansible_inventory() {
    log_info "Génération de l'inventaire Ansible..."
    
    cd ansible
    
    # Génération de l'inventaire dynamique
    python3 << 'EOF'
import json
import sys

try:
    with open('terraform_outputs.json', 'r') as f:
        outputs = json.load(f)
    
    minecraft_ip = outputs['minecraft_server_ip']['value']
    monitoring_ip = outputs['monitoring_server_ip']['value']
    
    inventory = f"""# Inventaire Ansible généré automatiquement pour TP Minecraft

all:
  children:
    minecraft_servers:
      hosts:
        minecraft-server:
          ansible_host: {minecraft_ip}
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          server_type: minecraft
          java_memory: "2G"
          minecraft_port: 25565
    
    monitoring_servers:
      hosts:
        monitoring-server:
          ansible_host: {monitoring_ip}
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          server_type: monitoring
          prometheus_port: 9090
          grafana_port: 3000
          grafana_admin_password: "admin123"
    
    all_servers:
      children:
        - minecraft_servers
        - monitoring_servers
"""
    
    with open('inventory.yml', 'w') as f:
        f.write(inventory)
    
    print("Inventaire Ansible généré avec succès")
    
except Exception as e:
    print(f"Erreur lors de la génération de l'inventaire: {e}")
    sys.exit(1)
EOF
    
    cd ..
    log_success "Inventaire Ansible généré"
}

# Déploiement Ansible
deploy_ansible() {
    log_info "Déploiement de la configuration Ansible..."
    
    cd ansible
    
    # Installation des collections
    log_info "Installation des collections Ansible..."
    ansible-galaxy install -r requirements.yml
    
    # Test de connectivité
    log_info "Test de connectivité SSH..."
    ansible all -i inventory.yml -m ping
    
    # Déploiement
    log_info "Déploiement de la configuration..."
    ansible-playbook -i inventory.yml playbook.yml
    
    cd ..
    log_success "Déploiement Ansible terminé"
}

# Affichage des informations de connexion
show_connection_info() {
    log_info "Récupération des informations de connexion..."
    
    cd terraform
    
    minecraft_ip=$(terraform output -raw minecraft_server_ip)
    monitoring_ip=$(terraform output -raw monitoring_server_ip)
    
    echo
    echo "========================================"
    echo "🎮 TP MINECRAFT - OBSERVABILITÉ"
    echo "========================================"
    echo
    echo "📡 Serveur Minecraft:"
    echo "   IP: $minecraft_ip"
    echo "   Port: 25565"
    echo "   Connexion: minecraft://$minecraft_ip:25565"
    echo "   SSH: ssh ubuntu@$minecraft_ip"
    echo
    echo "📊 Serveur de Monitoring:"
    echo "   IP: $monitoring_ip"
    echo "   Prometheus: http://$monitoring_ip:9090"
    echo "   Grafana: http://$monitoring_ip:3000"
    echo "   Login Grafana: admin / admin123"
    echo "   SSH: ssh ubuntu@$monitoring_ip"
    echo
    echo "========================================"
    echo "🚀 Déploiement terminé avec succès !"
    echo "========================================"
    
    cd ..
}

# Fonction principale
main() {
    echo "🎮 Déploiement TP Minecraft - Observabilité"
    echo "=========================================="
    echo
    
    check_prerequisites
    deploy_terraform
    generate_ansible_inventory
    deploy_ansible
    show_connection_info
    
    log_success "Déploiement complet terminé !"
}

# Gestion des erreurs
trap 'log_error "Erreur lors du déploiement. Vérifiez les logs ci-dessus."' ERR

# Exécution du script
main "$@"
