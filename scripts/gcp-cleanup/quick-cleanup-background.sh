#!/bin/bash
# Script rapide de nettoyage GCP - Suppression en arrière-plan
# UTILISEZ AVEC PRÉCAUTION - DESTRUCTION IRRÉVERSIBLE !

# Configuration du projet (à modifier selon votre projet)
PROJECT_ID="level-surfer-473817-p5"

# Configurer le projet
gcloud config set project "$PROJECT_ID" 2>/dev/null

echo "🚨 NETTOYAGE RAPIDE GCP - DESTRUCTION COMPLÈTE"
echo "=============================================="
echo "Projet: $PROJECT_ID"
echo "Date: $(date)"
echo

# Confirmation de sécurité
echo "⚠️ ATTENTION: Cette action va supprimer DÉFINITIVEMENT:"
echo "   - Toutes les instances Compute Engine"
echo "   - Tous les disques persistants"
echo "   - Toutes les adresses IP statiques"
echo "   - Tous les load balancers"
echo "   - Toutes les instances Cloud SQL"
echo "   - Tous les clusters GKE"
echo "   - Tous les buckets Cloud Storage"
echo "   - Tous les VPC personnalisés"
echo
read -p "Tapez 'DESTROY' pour confirmer: " -r
if [[ $REPLY != "DESTROY" ]]; then
    echo "❌ Destruction annulée"
    exit 1
fi

echo "🗑️ Début de la destruction en parallèle..."
echo

# Fonction pour supprimer en arrière-plan
delete_background() {
    local resource_type="$1"
    local list_command="$2"
    local delete_template="$3"
    
    echo "🔄 Suppression des $resource_type en parallèle..."
    
    # Lancer toutes les suppressions en arrière-plan
    eval "$list_command" 2>/dev/null | while read -r line; do
        if [ -n "$line" ]; then
            # Construire et exécuter la commande de suppression en arrière-plan
            local delete_cmd=$(echo "$line" | awk -v template="$delete_template" '{print template}')
            echo "  Lancement: $delete_cmd"
            eval "$delete_cmd" 2>/dev/null &
        fi
    done
    
    # Attendre que toutes les suppressions se terminent
    wait
    echo "✅ $resource_type supprimés"
    echo
}

# 1. Supprimer toutes les instances Compute Engine en parallèle
delete_background "instances Compute Engine" \
    "gcloud compute instances list --format='value(name,zone)'" \
    "gcloud compute instances delete {1} --zone={2} --quiet"

# 2. Supprimer tous les disques persistants en parallèle
delete_background "disques persistants" \
    "gcloud compute disks list --format='value(name,zone)'" \
    "gcloud compute disks delete {1} --zone={2} --quiet"

# 3. Supprimer toutes les adresses IP statiques en parallèle
delete_background "adresses IP statiques" \
    "gcloud compute addresses list --format='value(name,region)'" \
    "gcloud compute addresses delete {1} --region={2} --quiet"

# 4. Supprimer les load balancers en parallèle
echo "⚖️ Suppression des load balancers en parallèle..."
# Forwarding rules
delete_background "forwarding rules" \
    "gcloud compute forwarding-rules list --format='value(name,region)'" \
    "gcloud compute forwarding-rules delete {1} --region={2} --quiet"

# URL maps
delete_background "URL maps" \
    "gcloud compute url-maps list --format='value(name)'" \
    "gcloud compute url-maps delete {1} --quiet"

# 5. Supprimer toutes les instances Cloud SQL en parallèle
delete_background "instances Cloud SQL" \
    "gcloud sql instances list --format='value(name)'" \
    "gcloud sql instances delete {1} --quiet"

# 6. Supprimer tous les clusters GKE en parallèle
delete_background "clusters GKE" \
    "gcloud container clusters list --format='value(name,zone)'" \
    "gcloud container clusters delete {1} --zone={2} --quiet"

# 7. Supprimer tous les buckets Cloud Storage en parallèle
echo "🪣 Suppression des buckets Cloud Storage en parallèle..."
gsutil ls 2>/dev/null | while read bucket; do
    if [ -n "$bucket" ]; then
        echo "  Lancement suppression: $bucket"
        gsutil rm -r "$bucket" 2>/dev/null &
    fi
done
wait
echo "✅ Buckets Cloud Storage supprimés"
echo

# 8. Supprimer les VPC personnalisées en parallèle
delete_background "VPC personnalisées" \
    "gcloud compute networks list --format='value(name)' | grep -v 'default'" \
    "gcloud compute networks delete {1} --quiet"

# 9. Supprimer les instances BigQuery en parallèle
delete_background "datasets BigQuery" \
    "gcloud bigquery datasets list --format='value(datasetId)'" \
    "bq rm -r -f {1}"

# 10. Supprimer les instances Cloud Spanner en parallèle
delete_background "instances Cloud Spanner" \
    "gcloud spanner instances list --format='value(name)'" \
    "gcloud spanner instances delete {1} --quiet"

echo "🎉 DESTRUCTION TERMINÉE !"
echo "💰 Vérifiez votre facturation GCP pour confirmer la suppression des coûts"
echo "📊 Consultez le Cloud Console pour voir l'état final"
