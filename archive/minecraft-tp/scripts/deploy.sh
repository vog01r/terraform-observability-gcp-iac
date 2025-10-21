#!/bin/bash
# Script de déploiement complet pour TP Minecraft - Observabilité
# Ce script déploie l'infrastructure Terraform et teste les installations

set -euo pipefail

echo "=== Déploiement TP Minecraft - Observabilité ==="

# Vérification des prérequis
echo "Vérification des prérequis..."
    
# Vérification de Terraform
    if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    
# Vérification de gcloud
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud CLI n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    
# Vérification de l'authentification GCP
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Vous n'êtes pas authentifié avec Google Cloud. Exécutez 'gcloud auth login' d'abord."
        exit 1
    fi
    
# Vérification du fichier de clé SSH
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "❌ Clé SSH publique non trouvée. Générez une clé SSH avec 'ssh-keygen -t rsa' d'abord."
        exit 1
    fi
    
echo "✅ Tous les prérequis sont satisfaits"

# Navigation vers le répertoire Terraform
cd "$(dirname "$0")/../terraform"

# Initialisation de Terraform
echo "Initialisation de Terraform..."
    terraform init
    
# Validation de la configuration
echo "Validation de la configuration Terraform..."
terraform validate

# Planification du déploiement
echo "Planification du déploiement..."
terraform plan -out=tfplan

# Confirmation avant déploiement
echo ""
echo "⚠️  Le déploiement va créer des ressources facturables sur Google Cloud."
echo "Déploiement automatique activé..."
    
    # Déploiement
echo "Déploiement de l'infrastructure..."
terraform apply tfplan

# Récupération des informations de déploiement
echo "Récupération des informations de déploiement..."
MINECRAFT_IP=$(terraform output -raw minecraft_server_ip)
MONITORING_IP=$(terraform output -raw monitoring_server_ip)

echo ""
echo "=== Déploiement terminé avec succès! ==="
echo ""
echo "📊 Informations de déploiement:"
echo "🖥️  Serveur Minecraft: $MINECRAFT_IP"
echo "📈 Serveur Monitoring: $MONITORING_IP"
echo ""
echo "🔗 URLs d'accès:"
echo "🎮 Minecraft: minecraft://$MINECRAFT_IP:25565"
echo "📊 Prometheus: http://$MONITORING_IP:9090"
echo "📈 Grafana: http://$MONITORING_IP:3000 (admin/admin123)"
echo ""
echo "🔑 Commandes SSH:"
echo "ssh -i ~/.ssh/id_rsa ubuntu@$MINECRAFT_IP"
echo "ssh -i ~/.ssh/id_rsa ubuntu@$MONITORING_IP"
echo ""
    
    # Test de connectivité
echo "🧪 Test de connectivité..."

# Test du serveur Minecraft
echo "Test du serveur Minecraft..."
if timeout 10 bash -c "</dev/tcp/$MINECRAFT_IP/25565" 2>/dev/null; then
    echo "✅ Serveur Minecraft accessible sur le port 25565"
else
    echo "⚠️  Serveur Minecraft non accessible (peut être en cours de démarrage)"
fi

# Test de Node Exporter
echo "Test de Node Exporter..."
if timeout 10 bash -c "</dev/tcp/$MINECRAFT_IP/9100" 2>/dev/null; then
    echo "✅ Node Exporter accessible sur le port 9100"
else
    echo "⚠️  Node Exporter non accessible (peut être en cours de démarrage)"
fi

# Test de Prometheus
echo "Test de Prometheus..."
if timeout 10 bash -c "</dev/tcp/$MONITORING_IP/9090" 2>/dev/null; then
    echo "✅ Prometheus accessible sur le port 9090"
else
    echo "⚠️  Prometheus non accessible (peut être en cours de démarrage)"
fi

# Test de Grafana
echo "Test de Grafana..."
if timeout 10 bash -c "</dev/tcp/$MONITORING_IP/3000" 2>/dev/null; then
    echo "✅ Grafana accessible sur le port 3000"
else
    echo "⚠️  Grafana non accessible (peut être en cours de démarrage)"
fi

echo ""
echo "📝 Prochaines étapes:"
echo "1. Attendez 5-10 minutes que tous les services soient complètement démarrés"
echo "2. Connectez-vous à Grafana avec admin/admin123"
echo "3. Importez le dashboard Minecraft depuis /var/lib/grafana/dashboards/"
echo "4. Testez la connexion au serveur Minecraft"
echo "5. Configurez les alertes dans Prometheus si nécessaire"
echo ""
echo "🗑️  Pour supprimer l'infrastructure: terraform destroy"
echo ""
echo "🎉 Déploiement terminé! Bon TP!"