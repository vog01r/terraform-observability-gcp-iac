#!/bin/bash
# Script de nettoyage GCP pour Cloud Shell - Suppression en parallèle
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

# 1. Supprimer toutes les instances Compute Engine en parallèle
echo "🖥️ Suppression des instances Compute Engine en parallèle..."
gcloud compute instances list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        echo "  Lancement suppression: $name en zone $zone"
        gcloud compute instances delete "$name" --zone="$zone" --quiet 2>/dev/null &
    fi
done
wait
echo "✅ Instances Compute Engine supprimées"
echo

# 2. Supprimer tous les disques persistants en parallèle
echo "💾 Suppression des disques persistants en parallèle..."
gcloud compute disks list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        echo "  Lancement suppression: $name en zone $zone"
        gcloud compute disks delete "$name" --zone="$zone" --quiet 2>/dev/null &
    fi
done
wait
echo "✅ Disques persistants supprimés"
echo

# 3. Supprimer toutes les adresses IP statiques en parallèle
echo "🌐 Suppression des adresses IP statiques en parallèle..."
gcloud compute addresses list --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ] && [ -n "$region" ]; then
        echo "  Lancement suppression: $name en région $region"
        gcloud compute addresses delete "$name" --region="$region" --quiet 2>/dev/null &
    fi
done
wait
echo "✅ Adresses IP statiques supprimées"
echo

# 4. Supprimer les load balancers en parallèle
echo "⚖️ Suppression des load balancers en parallèle..."
# Forwarding rules
gcloud compute forwarding-rules list --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ] && [ -n "$region" ]; then
        echo "  Lancement suppression forwarding rule: $name en région $region"
        gcloud compute forwarding-rules delete "$name" --region="$region" --quiet 2>/dev/null &
    fi
done
# URL maps
gcloud compute url-maps list --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ]; then
        echo "  Lancement suppression URL map: $name"
        gcloud compute url-maps delete "$name" --quiet 2>/dev/null &
    fi
done
wait
echo "✅ Load balancers supprimés"
echo

# 5. Supprimer toutes les instances Cloud SQL en parallèle
echo "🗄️ Suppression des instances Cloud SQL en parallèle..."
gcloud sql instances list --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ]; then
        echo "  Lancement suppression: $name"
        gcloud sql instances delete "$name" --quiet 2>/dev/null &
    fi
done
wait
echo "✅ Instances Cloud SQL supprimées"
echo

# 6. Supprimer tous les clusters GKE en parallèle
echo "☸️ Suppression des clusters GKE en parallèle..."
gcloud container clusters list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        echo "  Lancement suppression: $name en zone $zone"
        gcloud container clusters delete "$name" --zone="$zone" --quiet 2>/dev/null &
    fi
done
wait
echo "✅ Clusters GKE supprimés"
echo

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
echo "🌐 Suppression des VPC personnalisées en parallèle..."
gcloud compute networks list --format="value(name)" 2>/dev/null | grep -v "default" | while read name; do
    if [ -n "$name" ]; then
        echo "  Lancement suppression: $name"
        gcloud compute networks delete "$name" --quiet 2>/dev/null &
    fi
done
wait
echo "✅ VPC personnalisées supprimées"
echo

# 9. Supprimer les instances BigQuery en parallèle
echo "📊 Suppression des datasets BigQuery en parallèle..."
gcloud bigquery datasets list --format="value(datasetId)" 2>/dev/null | while read dataset; do
    if [ -n "$dataset" ]; then
        echo "  Lancement suppression dataset: $dataset"
        bq rm -r -f "$dataset" 2>/dev/null &
    fi
done
wait
echo "✅ Datasets BigQuery supprimés"
echo

# 10. Supprimer les instances Cloud Spanner en parallèle
echo "🔍 Suppression des instances Cloud Spanner en parallèle..."
gcloud spanner instances list --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ]; then
        echo "  Lancement suppression: $name"
        gcloud spanner instances delete "$name" --quiet 2>/dev/null &
    fi
done
wait
echo "✅ Instances Cloud Spanner supprimées"
echo

echo "🎉 DESTRUCTION TERMINÉE !"
echo "💰 Vérifiez votre facturation GCP pour confirmer la suppression des coûts"
echo "📊 Consultez le Cloud Console pour voir l'état final"