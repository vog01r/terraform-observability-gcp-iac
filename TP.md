# TP Observabilité - Infrastructure GCP avec Terraform et Ansible

## 📋 Informations Générales

- **Durée estimée** : 10 heures
- **Niveau** : Intermédiaire
- **Technologies** : GCP, Terraform, Ansible, Zabbix, Grafana, Flask
- **Objectif** : Déployer et configurer une infrastructure d'observabilité complète

## 🎯 Objectifs Pédagogiques

À la fin de ce TP, vous serez capable de :

1. **Infrastructure as Code** : Utiliser Terraform pour déployer des ressources GCP
2. **Configuration Management** : Automatiser la configuration avec Ansible
3. **Monitoring** : Mettre en place Zabbix pour la surveillance
4. **Visualisation** : Configurer Grafana pour les tableaux de bord
5. **Intégration** : Connecter tous les composants pour un monitoring complet

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VM App        │    │   VM Zabbix     │    │   VM Grafana    │
│   (Flask)       │    │   (Server)      │    │   (Dashboard)   │
│                 │    │                 │    │                 │
│  - Flask App    │    │  - Zabbix       │    │  - Grafana      │
│  - Zabbix Agent │◄──►│  - MariaDB      │◄──►│  - Zabbix Plugin│
│  - Port 5000    │    │  - Port 10051   │    │  - Port 3000    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   VPC GCP       │
                    │   (10.42.0.0/24)│
                    └─────────────────┘
```

## 📚 Prérequis

### Logiciels Requis
- **Terraform** >= 1.0
- **Ansible** >= 2.9
- **gcloud CLI** (Google Cloud SDK)
- **Git**
- **Make** (optionnel mais recommandé)

### Compte GCP
- Projet GCP actif avec facturation activée
- Service Account avec permissions :
  - Compute Admin
  - Network Admin
  - Service Account User
- Clé JSON du Service Account

### Clé SSH
- Paire de clés SSH générée
- Clé publique accessible

## 🚀 Étapes du TP

### Étape 1 : Préparation de l'Environnement (30 min)

#### 1.1 Configuration GCP
```bash
# Authentification GCP
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Configuration des variables d'environnement
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
```

#### 1.2 Configuration du Projet
```bash
# Cloner le projet
git clone <REPO_URL>
cd observability

# Configuration des variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

#### 1.3 Édition du fichier terraform.tfvars
```hcl
project_id = "votre-project-id"
region     = "us-central1"
zone       = "us-central1-a"

ssh_user             = "ubuntu"
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
```

### Étape 2 : Déploiement Infrastructure (1h)

#### 2.1 Initialisation Terraform
```bash
make init
# ou
terraform -chdir=terraform init
```

#### 2.2 Planification
```bash
make plan
# ou
terraform -chdir=terraform plan
```

**Vérifications attendues :**
- 1 VPC network
- 1 subnet
- 5 firewall rules
- 3 instances Compute Engine
- 1 fichier d'inventaire Ansible

#### 2.3 Déploiement
```bash
make apply
# ou
terraform -chdir=terraform apply -auto-approve
```

**Résultats attendus :**
- Infrastructure créée avec succès
- Adresses IP assignées
- Inventaire Ansible généré

### Étape 3 : Configuration des VMs (2h)

#### 3.1 Vérification de la Connectivité SSH
```bash
make wait-ssh
# ou
bash scripts/check-ssh.sh
```

#### 3.2 Exécution du Playbook Ansible
```bash
make provision
# ou
ansible-playbook -i ansible/inventory/inventory.ini ansible/site.yml
```

**Étapes d'exécution :**
1. Configuration commune (packages, firewall, timezone)
2. Installation Zabbix Server + MariaDB
3. Configuration Flask App + Agent Zabbix
4. Installation Grafana + Plugin Zabbix

### Étape 4 : Validation et Tests (1h)

#### 4.1 Vérification des Services
```bash
# Affichage des URLs
make outputs

# Test de l'application Flask
curl http://APP_IP:5000/
curl http://APP_IP:5000/health
curl http://APP_IP:5000/stats
```

#### 4.2 Accès aux Interfaces Web

**Zabbix (http://ZABBIX_IP/zabbix)**
- Utilisateur : `Admin`
- Mot de passe : `zabbix`
- Vérifier la présence du host `app-linux`

**Grafana (http://GRAFANA_IP:3000)**
- Utilisateur : `admin`
- Mot de passe : `admin`
- Vérifier la datasource Zabbix
- Consulter le dashboard Flask

### Étape 5 : Exploration et Personnalisation (2h)

#### 5.1 Configuration Zabbix
1. **Ajout d'Items Personnalisés**
   - Aller dans Configuration → Hosts → app-linux → Items
   - Vérifier les items `flask.*`

2. **Création de Triggers**
   - Créer un trigger pour `flask.error_rate > 5%`
   - Configurer les actions et notifications

3. **Dashboard Zabbix**
   - Créer un dashboard personnalisé
   - Ajouter des graphiques pour les métriques Flask

#### 5.2 Configuration Grafana
1. **Dashboard Personnalisé**
   - Créer un nouveau dashboard
   - Ajouter des panels pour :
     - Uptime de l'application
     - Taux d'erreur
     - Nombre de requêtes

2. **Alerting**
   - Configurer des alertes basées sur les métriques
   - Tester les notifications

### Étape 6 : Tests de Charge et Monitoring (1h)

#### 6.1 Génération de Charge
```bash
# Script de test simple
for i in {1..100}; do
  curl http://APP_IP:5000/health &
done
wait
```

#### 6.2 Observation des Métriques
- Surveiller les graphiques en temps réel
- Vérifier la détection des erreurs
- Analyser les performances

### Étape 7 : Nettoyage (30 min)

#### 7.1 Destruction de l'Infrastructure
```bash
make destroy
# ou
terraform -chdir=terraform destroy -auto-approve
```

## 📊 Captures d'Écran Attendues

### 1. Interface Zabbix
- **Login** : Page de connexion Zabbix
- **Hosts** : Liste des hosts avec `app-linux` en statut "Available"
- **Items** : Items personnalisés `flask.*` avec données
- **Dashboard** : Graphiques des métriques Flask

### 2. Interface Grafana
- **Login** : Page de connexion Grafana
- **Datasources** : Datasource Zabbix configurée et testée
- **Dashboard** : Dashboard Flask avec 3 panels fonctionnels
- **Explore** : Requêtes sur les métriques Zabbix

### 3. Application Flask
- **Home** : Page d'accueil avec message de statut
- **Health** : Endpoint de santé avec réponse JSON
- **Stats** : Métriques en temps réel (uptime, erreurs, taux)

## 🎯 Barème de Validation

| Critère | Points | Description |
|---------|--------|-------------|
| **Infrastructure** | 20 | Déploiement Terraform réussi |
| **Configuration** | 20 | Playbook Ansible sans erreur |
| **Zabbix** | 20 | Host configuré, items fonctionnels |
| **Grafana** | 20 | Datasource OK, dashboard opérationnel |
| **Tests** | 10 | Application Flask accessible |
| **Documentation** | 10 | Captures d'écran, rapport |

**Total : 100 points**

### Critères de Réussite
- ✅ Infrastructure déployée sans erreur
- ✅ Tous les services accessibles
- ✅ Monitoring fonctionnel
- ✅ Dashboard avec données
- ✅ Tests de charge réussis

## 🔧 Dépannage

### Problèmes Courants

#### 1. Erreur de Quota GCP
```
Error: Quota 'CPUS_ALL_REGIONS' exceeded
```
**Solution** : Réduire les types de machines ou demander une augmentation de quota

#### 2. Échec de Connexion SSH
```
ssh: connect to host IP port 22: Connection timed out
```
**Solution** : Vérifier les firewall rules et attendre le démarrage des VMs

#### 3. Playbook Ansible Échoue
```
TASK [zabbix_server : Import Zabbix database schema] FAILED
```
**Solution** : Vérifier la connectivité réseau et les permissions

#### 4. Datasource Grafana Non Fonctionnelle
```
Failed to connect to Zabbix API
```
**Solution** : Vérifier l'URL de l'API et les credentials

## 📚 Ressources Supplémentaires

### Documentation
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Ansible GCP Modules](https://docs.ansible.com/ansible/latest/collections/google/cloud/)
- [Zabbix Documentation](https://www.zabbix.com/documentation/current)
- [Grafana Documentation](https://grafana.com/docs/)

### Commandes Utiles
```bash
# Vérifier l'état des VMs
gcloud compute instances list

# Consulter les logs
gcloud logging read "resource.type=gce_instance"

# Tester la connectivité
telnet IP 22
telnet IP 10051
telnet IP 3000

# Debug Ansible
ansible-playbook -i inventory/inventory.ini site.yml -vvv
```

## 🎉 Conclusion

Ce TP vous a permis de :
- Maîtriser l'Infrastructure as Code avec Terraform
- Automatiser la configuration avec Ansible
- Mettre en place un monitoring complet
- Intégrer des outils de visualisation

Ces compétences sont essentielles pour tout ingénieur DevOps/Cloud souhaitant déployer des infrastructures modernes et observables.
