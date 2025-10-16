#!/bin/bash
# Script rapide de nettoyage GCP - Suppression en parallèle
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

# Fonction pour supprimer en parallèle
delete_parallel() {
    local resource_type="$1"
    local list_command="$2"
    local delete_command="$3"
    
    echo "🔄 Suppression des $resource_type en parallèle..."
    
    # Créer un fichier temporaire pour stocker les commandes
    local temp_file=$(mktemp)
    
    # Générer toutes les commandes de suppression
    eval "$list_command" 2>/dev/null | while read -r line; do
        if [ -n "$line" ]; then
            # Construire la commande de suppression
            local delete_cmd=$(echo "$line" | awk -v cmd="$delete_command" '{print cmd}')
            echo "$delete_cmd" >> "$temp_file"
        fi
    done
    
    # Exécuter toutes les commandes en parallèle
    if [ -s "$temp_file" ]; then
        echo "  Exécution de $(wc -l < "$temp_file") suppressions en parallèle..."
        parallel -j 10 < "$temp_file" 2>/dev/null || {
            # Si parallel n'est pas disponible, utiliser xargs
            cat "$temp_file" | xargs -P 10 -I {} bash -c "{}" 2>/dev/null || {
                # Fallback: exécution séquentielle
                while IFS= read -r cmd; do
                    eval "$cmd" 2>/dev/null || echo "    ❌ Échec: $cmd"
                done < "$temp_file"
            }
        }
    else
        echo "  Aucune $resource_type trouvée"
    fi
    
    # Nettoyer le fichier temporaire
    rm -f "$temp_file"
    echo "✅ $resource_type supprimés"
    echo
}

# 1. Supprimer toutes les instances Compute Engine en parallèle
delete_parallel "instances Compute Engine" \
    "gcloud compute instances list --format='value(name,zone)'" \
    "gcloud compute instances delete {1} --zone={2} --quiet"

# 2. Supprimer tous les disques persistants en parallèle
delete_parallel "disques persistants" \
    "gcloud compute disks list --format='value(name,zone)'" \
    "gcloud compute disks delete {1} --zone={2} --quiet"

# 3. Supprimer toutes les adresses IP statiques en parallèle
delete_parallel "adresses IP statiques" \
    "gcloud compute addresses list --format='value(name,region)'" \
    "gcloud compute addresses delete {1} --region={2} --quiet"

# 4. Supprimer les load balancers en parallèle
echo "⚖️ Suppression des load balancers en parallèle..."
# Forwarding rules
delete_parallel "forwarding rules" \
    "gcloud compute forwarding-rules list --format='value(name,region)'" \
    "gcloud compute forwarding-rules delete {1} --region={2} --quiet"

# URL maps
delete_parallel "URL maps" \
    "gcloud compute url-maps list --format='value(name)'" \
    "gcloud compute url-maps delete {1} --quiet"

# 5. Supprimer toutes les instances Cloud SQL en parallèle
delete_parallel "instances Cloud SQL" \
    "gcloud sql instances list --format='value(name)'" \
    "gcloud sql instances delete {1} --quiet"

# 6. Supprimer tous les clusters GKE en parallèle
delete_parallel "clusters GKE" \
    "gcloud container clusters list --format='value(name,zone)'" \
    "gcloud container clusters delete {1} --zone={2} --quiet"

# 7. Supprimer tous les buckets Cloud Storage en parallèle
echo "🪣 Suppression des buckets Cloud Storage en parallèle..."
gsutil ls 2>/dev/null | while read bucket; do
    if [ -n "$bucket" ]; then
        echo "  Suppression de: $bucket"
        gsutil rm -r "$bucket" 2>/dev/null &
    fi
done
wait
echo "✅ Buckets Cloud Storage supprimés"
echo

# 8. Supprimer les VPC personnalisées en parallèle
delete_parallel "VPC personnalisées" \
    "gcloud compute networks list --format='value(name)' | grep -v 'default'" \
    "gcloud compute networks delete {1} --quiet"

# 9. Supprimer les instances BigQuery en parallèle
delete_parallel "datasets BigQuery" \
    "gcloud bigquery datasets list --format='value(datasetId)'" \
    "bq rm -r -f {1}"

# 10. Supprimer les instances Cloud Spanner en parallèle
delete_parallel "instances Cloud Spanner" \
    "gcloud spanner instances list --format='value(name)'" \
    "gcloud spanner instances delete {1} --quiet"

echo "🎉 DESTRUCTION TERMINÉE !"
echo "💰 Vérifiez votre facturation GCP pour confirmer la suppression des coûts"
echo "📊 Consultez le Cloud Console pour voir l'état final"
