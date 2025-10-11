#!/bin/bash
# Script rapide de nettoyage GCP - Prêt à copier-coller dans Cloud Shell
# UTILISEZ AVEC PRÉCAUTION - DESTRUCTION IRRÉVERSIBLE !

echo "🚨 NETTOYAGE RAPIDE GCP - DESTRUCTION COMPLÈTE"
echo "=============================================="
echo "Projet: $(gcloud config get-value project)"
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

echo "🗑️ Début de la destruction..."
echo

# 1. Supprimer toutes les instances Compute Engine
echo "🖥️ Suppression des instances Compute Engine..."
gcloud compute instances list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        echo "  Suppression de: $name en zone $zone"
        gcloud compute instances delete "$name" --zone="$zone" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
echo "✅ Instances Compute Engine supprimées"
echo

# 2. Supprimer tous les disques persistants
echo "💾 Suppression des disques persistants..."
gcloud compute disks list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        echo "  Suppression de: $name en zone $zone"
        gcloud compute disks delete "$name" --zone="$zone" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
echo "✅ Disques persistants supprimés"
echo

# 3. Supprimer toutes les adresses IP statiques
echo "🌐 Suppression des adresses IP statiques..."
gcloud compute addresses list --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ] && [ -n "$region" ]; then
        echo "  Suppression de: $name en région $region"
        gcloud compute addresses delete "$name" --region="$region" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
echo "✅ Adresses IP statiques supprimées"
echo

# 4. Supprimer les load balancers
echo "⚖️ Suppression des load balancers..."
# Forwarding rules
gcloud compute forwarding-rules list --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ] && [ -n "$region" ]; then
        echo "  Suppression de la forwarding rule: $name en région $region"
        gcloud compute forwarding-rules delete "$name" --region="$region" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
# URL maps
gcloud compute url-maps list --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ]; then
        echo "  Suppression de l'URL map: $name"
        gcloud compute url-maps delete "$name" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
echo "✅ Load balancers supprimés"
echo

# 5. Supprimer toutes les instances Cloud SQL
echo "🗄️ Suppression des instances Cloud SQL..."
gcloud sql instances list --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ]; then
        echo "  Suppression de: $name"
        gcloud sql instances delete "$name" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
echo "✅ Instances Cloud SQL supprimées"
echo

# 6. Supprimer tous les clusters GKE
echo "☸️ Suppression des clusters GKE..."
gcloud container clusters list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        echo "  Suppression de: $name en zone $zone"
        gcloud container clusters delete "$name" --zone="$zone" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
echo "✅ Clusters GKE supprimés"
echo

# 7. Supprimer tous les buckets Cloud Storage
echo "🪣 Suppression des buckets Cloud Storage..."
gsutil ls 2>/dev/null | while read bucket; do
    if [ -n "$bucket" ]; then
        echo "  Suppression de: $bucket"
        gsutil rm -r "$bucket" 2>/dev/null || echo "    ❌ Échec: $bucket"
    fi
done
echo "✅ Buckets Cloud Storage supprimés"
echo

# 8. Supprimer les VPC personnalisées (garder default)
echo "🌐 Suppression des VPC personnalisées..."
gcloud compute networks list --format="value(name)" 2>/dev/null | grep -v "default" | while read name; do
    if [ -n "$name" ]; then
        echo "  Suppression de: $name"
        gcloud compute networks delete "$name" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
echo "✅ VPC personnalisées supprimées"
echo

# 9. Supprimer les instances BigQuery
echo "📊 Suppression des datasets BigQuery..."
gcloud bigquery datasets list --format="value(datasetId)" 2>/dev/null | while read dataset; do
    if [ -n "$dataset" ]; then
        echo "  Suppression du dataset: $dataset"
        bq rm -r -f "$dataset" 2>/dev/null || echo "    ❌ Échec: $dataset"
    fi
done
echo "✅ Datasets BigQuery supprimés"
echo

# 10. Supprimer les instances Cloud Spanner
echo "🔍 Suppression des instances Cloud Spanner..."
gcloud spanner instances list --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ]; then
        echo "  Suppression de: $name"
        gcloud spanner instances delete "$name" --quiet 2>/dev/null || echo "    ❌ Échec: $name"
    fi
done
echo "✅ Instances Cloud Spanner supprimées"
echo

echo "🎉 DESTRUCTION TERMINÉE !"
echo "💰 Vérifiez votre facturation GCP pour confirmer la suppression des coûts"
echo "📊 Consultez le Cloud Console pour voir l'état final"
