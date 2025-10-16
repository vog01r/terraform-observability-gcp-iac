#!/bin/bash
# Script de configuration du projet GCP dans Cloud Shell

echo "🔧 CONFIGURATION DU PROJET GCP"
echo "=============================="
echo

# Lister tous les projets disponibles
echo "📋 Projets GCP disponibles :"
echo "----------------------------"
gcloud projects list --format="table(projectId,name,projectNumber)" 2>/dev/null || {
    echo "❌ Erreur: Impossible de lister les projets"
    echo "Vérifiez votre authentification avec: gcloud auth login"
    exit 1
}
echo

# Demander le projet à utiliser
echo "💡 Sélectionnez votre projet :"
echo "1. Entrez l'ID du projet (ex: my-project-123456)"
echo "2. Ou appuyez sur Entrée pour utiliser le premier projet de la liste"
echo
read -p "ID du projet (ou Entrée pour auto-sélection): " -r PROJECT_ID

# Si aucun projet spécifié, utiliser le premier
if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(gcloud projects list --format="value(projectId)" --limit=1 2>/dev/null)
    if [ -z "$PROJECT_ID" ]; then
        echo "❌ Aucun projet trouvé"
        exit 1
    fi
    echo "✅ Projet auto-sélectionné: $PROJECT_ID"
fi

# Configurer le projet
echo "🔧 Configuration du projet: $PROJECT_ID"
gcloud config set project "$PROJECT_ID" 2>/dev/null || {
    echo "❌ Erreur: Impossible de configurer le projet $PROJECT_ID"
    echo "Vérifiez que vous avez accès à ce projet"
    exit 1
}

# Vérifier la configuration
echo "✅ Projet configuré avec succès !"
echo "Projet actuel: $(gcloud config get-value project)"
echo

# Activer les APIs nécessaires
echo "🚀 Activation des APIs nécessaires..."
gcloud services enable compute.googleapis.com 2>/dev/null || echo "⚠️ API Compute déjà activée"
gcloud services enable sqladmin.googleapis.com 2>/dev/null || echo "⚠️ API SQL déjà activée"
gcloud services enable container.googleapis.com 2>/dev/null || echo "⚠️ API Container déjà activée"
gcloud services enable storage-api.googleapis.com 2>/dev/null || echo "⚠️ API Storage déjà activée"
gcloud services enable bigquery.googleapis.com 2>/dev/null || echo "⚠️ API BigQuery déjà activée"
gcloud services enable spanner.googleapis.com 2>/dev/null || echo "⚠️ API Spanner déjà activée"

echo "✅ APIs activées"
echo

echo "🎉 Configuration terminée !"
echo "Vous pouvez maintenant utiliser les scripts de listing et de nettoyage"
echo
echo "Commandes disponibles :"
echo "  ./list-all.sh          # Lister toutes les ressources"
echo "  ./quick-cleanup.sh     # Supprimer toutes les ressources"
echo
