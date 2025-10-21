#!/bin/bash

# Script de destruction pour TP Minecraft - Observabilité
# Ce script supprime complètement l'infrastructure déployée

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

# Destruction de l'infrastructure
destroy_infrastructure() {
    log_info "Destruction de l'infrastructure Terraform..."
    
    cd terraform
    
    # Vérification de l'état
    if [ ! -f terraform.tfstate ]; then
        log_warning "Aucun état Terraform trouvé. Rien à détruire."
        return 0
    fi
    
    # Plan de destruction
    log_info "Planification de la destruction..."
    terraform plan -destroy
    
    # Confirmation
    echo
    log_warning "⚠️  ATTENTION: Cette action va supprimer définitivement:"
    echo "   - Les serveurs Minecraft et de monitoring"
    echo "   - Les adresses IP publiques"
    echo "   - Le VPC et les règles de firewall"
    echo "   - Toutes les données stockées"
    echo
    read -p "Êtes-vous sûr de vouloir continuer ? Tapez 'DESTROY' pour confirmer: " -r
    echo
    
    if [[ $REPLY != "DESTROY" ]]; then
        log_warning "Destruction annulée"
        exit 0
    fi
    
    # Destruction
    log_info "Destruction en cours..."
    terraform destroy -auto-approve
    
    cd ..
    log_success "Infrastructure supprimée avec succès"
}

# Nettoyage des fichiers temporaires
cleanup_files() {
    log_info "Nettoyage des fichiers temporaires..."
    
    # Suppression des fichiers de sortie Terraform
    if [ -f ansible/terraform_outputs.json ]; then
        rm ansible/terraform_outputs.json
        log_info "Fichier terraform_outputs.json supprimé"
    fi
    
    # Suppression des fichiers de cache Ansible
    if [ -d ansible/.ansible ]; then
        rm -rf ansible/.ansible
        log_info "Cache Ansible supprimé"
    fi
    
    log_success "Nettoyage terminé"
}

# Fonction principale
main() {
    echo "🗑️  Destruction TP Minecraft - Observabilité"
    echo "============================================="
    echo
    
    destroy_infrastructure
    cleanup_files
    
    echo
    echo "========================================"
    echo "✅ Destruction terminée avec succès !"
    echo "========================================"
    echo
    log_info "Tous les ressources ont été supprimées"
    log_info "Vous pouvez maintenant redéployer si nécessaire"
}

# Gestion des erreurs
trap 'log_error "Erreur lors de la destruction. Vérifiez les logs ci-dessus."' ERR

# Exécution du script
main "$@"
