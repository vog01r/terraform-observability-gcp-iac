# 🧹 Nettoyage Google Cloud Platform - Suppression des Ressources Payantes

## ⚠️ ATTENTION - DESTRUCTION COMPLÈTE

Ce guide contient des commandes pour **SUPPRIMER DÉFINITIVEMENT** toutes les ressources payantes sur Google Cloud Platform.

**🚨 UTILISEZ CES COMMANDES AVEC PRÉCAUTION ! 🚨**

## 📋 Prérequis

1. **Cloud Shell** ou **gcloud CLI** installé
2. **Authentification** : `gcloud auth login`
3. **Projet sélectionné** : `gcloud config set project YOUR_PROJECT_ID`

## 🔍 1. LISTER TOUTES LES RESSOURCES PAYANTES

### Script complet de listing (à copier-coller dans Cloud Shell)

```bash
#!/bin/bash
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
```

## 🗑️ 2. SUPPRIMER TOUTES LES RESSOURCES PAYANTES

### Script de destruction complète (à copier-coller dans Cloud Shell)

```bash
#!/bin/bash
echo "🚨 DESTRUCTION COMPLÈTE DES RESSOURCES GCP"
echo "=========================================="
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
```

## 🔧 3. COMMANDES INDIVIDUELLES (à copier-coller)

### Lister les ressources par type

```bash
# Instances Compute Engine
gcloud compute instances list --format="table(name,zone,status,machineType,creationTimestamp)"

# Disques persistants
gcloud compute disks list --format="table(name,zone,sizeGb,type,creationTimestamp)"

# Adresses IP statiques
gcloud compute addresses list --format="table(name,region,address,status)"

# Load balancers
gcloud compute forwarding-rules list --format="table(name,region,IPAddress,target)"
gcloud compute url-maps list --format="table(name,defaultService)"

# Instances Cloud SQL
gcloud sql instances list --format="table(name,region,databaseVersion,tier,state)"

# Clusters GKE
gcloud container clusters list --format="table(name,zone,status,numNodes,currentMasterVersion)"

# Buckets Cloud Storage
gsutil ls -l

# VPC personnalisées
gcloud compute networks list --format="table(name,subnetMode,autoCreateSubnetworks)"

# Datasets BigQuery
gcloud bigquery datasets list --format="table(datasetId,location,creationTime)"

# Instances Cloud Spanner
gcloud spanner instances list --format="table(name,config,displayName,nodeCount,state)"
```

### Supprimer les ressources par type

```bash
# Supprimer toutes les instances Compute Engine
gcloud compute instances list --format="value(name,zone)" | while read name zone; do
    gcloud compute instances delete "$name" --zone="$zone" --quiet
done

# Supprimer tous les disques persistants
gcloud compute disks list --format="value(name,zone)" | while read name zone; do
    gcloud compute disks delete "$name" --zone="$zone" --quiet
done

# Supprimer toutes les adresses IP statiques
gcloud compute addresses list --format="value(name,region)" | while read name region; do
    gcloud compute addresses delete "$name" --region="$region" --quiet
done

# Supprimer tous les load balancers
gcloud compute forwarding-rules list --format="value(name,region)" | while read name region; do
    gcloud compute forwarding-rules delete "$name" --region="$region" --quiet
done

# Supprimer toutes les instances Cloud SQL
gcloud sql instances list --format="value(name)" | while read name; do
    gcloud sql instances delete "$name" --quiet
done

# Supprimer tous les clusters GKE
gcloud container clusters list --format="value(name,zone)" | while read name zone; do
    gcloud container clusters delete "$name" --zone="$zone" --quiet
done

# Supprimer tous les buckets Cloud Storage
gsutil ls | while read bucket; do
    gsutil rm -r "$bucket"
done

# Supprimer les VPC personnalisées (garder default)
gcloud compute networks list --format="value(name)" | grep -v "default" | while read name; do
    gcloud compute networks delete "$name" --quiet
done

# Supprimer les datasets BigQuery
gcloud bigquery datasets list --format="value(datasetId)" | while read dataset; do
    bq rm -r -f "$dataset"
done

# Supprimer les instances Cloud Spanner
gcloud spanner instances list --format="value(name)" | while read name; do
    gcloud spanner instances delete "$name" --quiet
done
```

## 🔍 4. VÉRIFICATION FINALE

### Script de vérification (à copier-coller)

```bash
#!/bin/bash
echo "🔍 VÉRIFICATION FINALE DES RESSOURCES RESTANTES"
echo "=============================================="
echo "Projet: $(gcloud config get-value project)"
echo "Date: $(date)"
echo

echo "🖥️ Instances Compute Engine restantes:"
gcloud compute instances list --format="value(name)" 2>/dev/null | wc -l
echo

echo "💾 Disques persistants restants:"
gcloud compute disks list --format="value(name)" 2>/dev/null | wc -l
echo

echo "🌐 Adresses IP statiques restantes:"
gcloud compute addresses list --format="value(name)" 2>/dev/null | wc -l
echo

echo "🗄️ Instances Cloud SQL restantes:"
gcloud sql instances list --format="value(name)" 2>/dev/null | wc -l
echo

echo "☸️ Clusters GKE restants:"
gcloud container clusters list --format="value(name)" 2>/dev/null | wc -l
echo

echo "🪣 Buckets Cloud Storage restants:"
gsutil ls 2>/dev/null | wc -l
echo

echo "🌐 VPC personnalisées restantes:"
gcloud compute networks list --format="value(name)" 2>/dev/null | grep -v "default" | wc -l
echo

echo "📊 Datasets BigQuery restants:"
gcloud bigquery datasets list --format="value(datasetId)" 2>/dev/null | wc -l
echo

echo "🔍 Instances Cloud Spanner restantes:"
gcloud spanner instances list --format="value(name)" 2>/dev/null | wc -l
echo

echo "✅ Vérification terminée"
echo "💰 Consultez le Cloud Console > Billing pour voir les coûts finaux"
```

## 🚨 5. PRÉCAUTIONS IMPORTANTES

### ⚠️ AVANT DE SUPPRIMER :
1. **Sauvegardez vos données** importantes
2. **Vérifiez la facturation** pour identifier les ressources coûteuses
3. **Testez sur un projet de test** avant de supprimer en production
4. **Informez votre équipe** si c'est un projet partagé

### 🛡️ PROTECTION CONTRE LES SUPPRESSIONS ACCIDENTELLES :
```bash
# Créer un projet de test
gcloud projects create test-project-$(date +%s)

# Basculer vers le projet de test
gcloud config set project test-project-XXXXX

# Tester les commandes de suppression
# ... vos tests ...

# Revenir au projet principal
gcloud config set project YOUR_MAIN_PROJECT
```

## 📊 6. MONITORING DES COÛTS

### Surveiller les coûts en temps réel
```bash
# Voir les coûts par service
gcloud billing budgets list

# Configurer des alertes de budget
gcloud billing budgets create \
    --billing-account=BILLING_ACCOUNT_ID \
    --display-name="Budget Alert" \
    --budget-amount=100USD \
    --threshold-rule=percent=90 \
    --threshold-rule=percent=100
```

## 🎯 7. RESSOURCES GRATUITES (À NE PAS SUPPRIMER)

Ces ressources sont gratuites et peuvent être conservées :
- **VPC par défaut** (`default`)
- **Règles de firewall par défaut**
- **Comptes de service**
- **IAM et permissions**
- **Logs Cloud Logging** (limite gratuite)

## 📚 8. RESSOURCES UTILES

- [Documentation GCP Billing](https://cloud.google.com/billing/docs)
- [Gestion des coûts GCP](https://cloud.google.com/cost-management)
- [Commandes gcloud](https://cloud.google.com/sdk/gcloud/reference)
- [Limites et quotas GCP](https://cloud.google.com/compute/quotas)

---

## ⚠️ RAPPEL IMPORTANT

**Ces commandes suppriment DÉFINITIVEMENT vos ressources GCP.**
**Assurez-vous d'avoir sauvegardé toutes vos données importantes avant d'exécuter ces commandes.**

**🚨 UTILISEZ CES COMMANDES AVEC PRÉCAUTION ! 🚨**