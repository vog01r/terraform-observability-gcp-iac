#!/bin/bash
# Script de listing complet des ressources GCP - Prêt à copier-coller dans Cloud Shell

echo "🔍 LISTAGE DE TOUTES LES RESSOURCES PAYANTES GCP"
echo "=============================================="
echo "Projet: $(gcloud config get-value project)"
echo "Date: $(date)"
echo

echo "🖥️ INSTANCES COMPUTE ENGINE:"
echo "----------------------------"
gcloud compute instances list --format="table(name,zone,status,machineType,creationTimestamp)" 2>/dev/null || echo "Aucune instance trouvée"
echo

echo "💾 DISQUES PERSISTANTS:"
echo "----------------------"
gcloud compute disks list --format="table(name,zone,sizeGb,type,creationTimestamp)" 2>/dev/null || echo "Aucun disque trouvé"
echo

echo "🌐 ADRESSES IP STATIQUES:"
echo "------------------------"
gcloud compute addresses list --format="table(name,region,address,status)" 2>/dev/null || echo "Aucune adresse IP trouvée"
echo

echo "⚖️ LOAD BALANCERS:"
echo "-----------------"
echo "Forwarding Rules:"
gcloud compute forwarding-rules list --format="table(name,region,IPAddress,target)" 2>/dev/null || echo "Aucune forwarding rule trouvée"
echo "URL Maps:"
gcloud compute url-maps list --format="table(name,defaultService)" 2>/dev/null || echo "Aucun URL map trouvé"
echo

echo "🗄️ INSTANCES CLOUD SQL:"
echo "----------------------"
gcloud sql instances list --format="table(name,region,databaseVersion,tier,state)" 2>/dev/null || echo "Aucune instance Cloud SQL trouvée"
echo

echo "☸️ CLUSTERS GKE:"
echo "---------------"
gcloud container clusters list --format="table(name,zone,status,numNodes,currentMasterVersion)" 2>/dev/null || echo "Aucun cluster GKE trouvé"
echo

echo "🪣 BUCKETS CLOUD STORAGE:"
echo "------------------------"
gsutil ls -l 2>/dev/null || echo "Aucun bucket trouvé"
echo

echo "🌐 VPC PERSONNALISÉES:"
echo "---------------------"
gcloud compute networks list --format="table(name,subnetMode,autoCreateSubnetworks)" 2>/dev/null || echo "Aucune VPC personnalisée trouvée"
echo

echo "📊 INSTANCES BIGQUERY:"
echo "---------------------"
gcloud bigquery datasets list --format="table(datasetId,location,creationTime)" 2>/dev/null || echo "Aucun dataset BigQuery trouvé"
echo

echo "🔍 INSTANCES CLOUD SPANNER:"
echo "--------------------------"
gcloud spanner instances list --format="table(name,config,displayName,nodeCount,state)" 2>/dev/null || echo "Aucune instance Spanner trouvée"
echo

echo "💰 ESTIMATION DES COÛTS:"
echo "-----------------------"
echo "Consultez le Cloud Console > Billing pour voir les coûts détaillés"
echo "URL: https://console.cloud.google.com/billing"
echo

echo "✅ LISTAGE TERMINÉ"
