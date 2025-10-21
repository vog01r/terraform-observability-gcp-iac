# 🚀 TP Observabilité - Infrastructure GCP avec Terraform et Ansible

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue.svg)](https://terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-red.svg)](https://ansible.com/)
[![GCP](https://img.shields.io/badge/GCP-Google%20Cloud-orange.svg)](https://cloud.google.com/)

Un projet complet d'observabilité déployant 3 VMs sur GCP avec monitoring Zabbix et visualisation Grafana, entièrement automatisé avec Terraform et Ansible.

## 🎯 Vue d'Ensemble

Ce projet déploie une infrastructure d'observabilité complète comprenant :

- **VM App** : Application Flask avec métriques personnalisées
- **VM Zabbix** : Serveur de monitoring avec base de données MariaDB
- **VM Grafana** : Interface de visualisation avec plugin Zabbix
- **VPC GCP** : Réseau privé avec règles de firewall sécurisées

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

## 🚀 Démarrage Rapide

### Prérequis

- **GCP Project** avec facturation activée
- **Service Account** avec permissions Compute Admin
- **Clé SSH** générée
- **Logiciels** : Terraform, Ansible, gcloud CLI

### Installation (5 minutes)

1. **Cloner le projet**
```bash
git clone <REPO_URL>
cd observability
```

2. **Configurer l'environnement GCP**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

3. **Configurer les variables**
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Éditer terraform.tfvars avec vos valeurs
```

4. **Déployer l'infrastructure complète**
```bash
make all
```

### Accès aux Services

Une fois le déploiement terminé :

- **Application Flask** : http://APP_IP:5000
- **Zabbix** : http://ZABBIX_IP/zabbix (Admin/zabbix)
- **Grafana** : http://GRAFANA_IP:3000 (admin/admin)

## 📁 Structure du Projet

```
.
├── README.md                    # Ce fichier
├── TP.md                       # Guide détaillé du TP
├── Makefile                    # Automatisation des tâches
├── .gitignore                  # Fichiers à ignorer
├── terraform/                  # Configuration Terraform
│   ├── main.tf                # Ressources principales
│   ├── outputs.tf             # Variables de sortie
│   ├── providers.tf           # Configuration des providers
│   ├── variables.tf           # Variables d'entrée
│   ├── terraform.tfvars.example # Exemple de configuration
│   └── templates/
│       └── inventory.ini.tmpl # Template inventaire Ansible
├── ansible/                    # Configuration Ansible
│   ├── ansible.cfg            # Configuration Ansible
│   ├── site.yml               # Playbook principal
│   ├── inventory/
│   │   ├── inventory.ini      # Inventaire généré par Terraform
│   │   └── group_vars/        # Variables par groupe
│   └── roles/                 # Rôles Ansible
│       ├── common/            # Configuration commune
│       ├── app/               # Application Flask
│       ├── zabbix_server/     # Serveur Zabbix
│       └── grafana/           # Grafana
└── scripts/                   # Scripts utilitaires
    ├── check-ssh.sh          # Vérification SSH
    └── export-tf-outputs.sh  # Export des outputs
```

## 🛠️ Commandes Disponibles

### Makefile

```bash
make help        # Afficher l'aide
make init        # Initialiser Terraform
make plan        # Planifier le déploiement
make apply       # Déployer l'infrastructure
make wait-ssh    # Attendre la connectivité SSH
make provision   # Configurer avec Ansible
make all         # Déploiement complet
make destroy     # Détruire l'infrastructure
make outputs     # Afficher les outputs
make check       # Vérifier la connectivité SSH
make clean       # Nettoyer les fichiers temporaires
```

### Commandes Terraform

```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan
terraform -chdir=terraform apply
terraform -chdir=terraform destroy
terraform -chdir=terraform output
```

### Commandes Ansible

```bash
ansible-playbook -i ansible/inventory/inventory.ini ansible/site.yml
ansible all -i ansible/inventory/inventory.ini -m ping
```

## 🔧 Configuration

### Variables Terraform

| Variable | Description | Défaut |
|----------|-------------|---------|
| `project_id` | ID du projet GCP | - |
| `region` | Région GCP | `us-central1` |
| `zone` | Zone GCP | `us-central1-a` |
| `network_cidr` | CIDR du réseau | `10.42.0.0/24` |
| `ssh_user` | Utilisateur SSH | `ubuntu` |
| `ssh_public_key_path` | Chemin clé SSH | `~/.ssh/id_rsa.pub` |

### Variables Ansible

Les variables sont définies dans `ansible/inventory/group_vars/` :

- **all.yml** : Configuration commune
- **app.yml** : Configuration application Flask
- **zabbix.yml** : Configuration Zabbix
- **grafana.yml** : Configuration Grafana

## 🔒 Sécurité

### Firewall Rules

- **SSH (22)** : Accès depuis 0.0.0.0/0 (⚠️ TODO: restreindre)
- **HTTP/HTTPS (80/443)** : Accès depuis 0.0.0.0/0
- **Grafana (3000)** : Accès depuis 0.0.0.0/0
- **Zabbix Agent (10050)** : Accès intra-VPC uniquement
- **Zabbix Server (10051)** : Accès intra-VPC uniquement

### Recommandations

1. **Restreindre SSH** aux IPs d'administration
2. **Changer les mots de passe** par défaut
3. **Activer HTTPS** pour les interfaces web
4. **Configurer des alertes** de sécurité

## 📊 Monitoring

### Métriques Collectées

- **Flask Uptime** : Temps de fonctionnement
- **Flask Errors** : Nombre d'erreurs
- **Flask Requests** : Nombre total de requêtes
- **Flask Error Rate** : Taux d'erreur en pourcentage

### Dashboards

- **Zabbix** : Monitoring système et application
- **Grafana** : Visualisation avancée avec plugin Zabbix

## 🧪 Tests

### Test de l'Application

```bash
# Test des endpoints
curl http://APP_IP:5000/          # Page d'accueil
curl http://APP_IP:5000/health    # Santé de l'application
curl http://APP_IP:5000/stats     # Métriques
```

### Test de Charge

```bash
# Génération de charge simple
for i in {1..100}; do
  curl http://APP_IP:5000/health &
done
wait
```

## 🔍 Dépannage

### Problèmes Courants

#### 1. Erreur de Quota GCP
```
Error: Quota 'CPUS_ALL_REGIONS' exceeded
```
**Solution** : Réduire les types de machines dans `terraform.tfvars`

#### 2. Échec de Connexion SSH
```
ssh: connect to host IP port 22: Connection timed out
```
**Solution** : Vérifier les firewall rules et attendre le démarrage

#### 3. Playbook Ansible Échoue
```
TASK [zabbix_server : Import Zabbix database schema] FAILED
```
**Solution** : Vérifier la connectivité réseau et les permissions

### Logs et Debug

```bash
# Logs Terraform
terraform -chdir=terraform apply -auto-approve 2>&1 | tee terraform.log

# Logs Ansible
ansible-playbook -i ansible/inventory/inventory.ini ansible/site.yml -vvv

# Logs GCP
gcloud logging read "resource.type=gce_instance"
```

## 💰 Coûts Estimés

| Ressource | Type | Coût/heure | Coût/jour |
|-----------|------|------------|-----------|
| VM App | e2-micro | ~$0.01 | ~$0.24 |
| VM Zabbix | e2-standard-2 | ~$0.07 | ~$1.68 |
| VM Grafana | e2-micro | ~$0.01 | ~$0.24 |
| **Total** | | **~$0.09** | **~$2.16** |

*Coûts approximatifs pour la région us-central1*

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

- **Issues** : [GitHub Issues](https://github.com/your-repo/issues)
- **Documentation** : [Wiki](https://github.com/your-repo/wiki)
- **Email** : support@example.com

## 🙏 Remerciements

- [Terraform](https://terraform.io/) pour l'Infrastructure as Code
- [Ansible](https://ansible.com/) pour l'automatisation
- [Zabbix](https://zabbix.com/) pour le monitoring
- [Grafana](https://grafana.com/) pour la visualisation
- [Google Cloud Platform](https://cloud.google.com/) pour l'infrastructure

---

**⚠️ Important** : N'oubliez pas de détruire l'infrastructure après vos tests pour éviter des coûts inutiles !

```bash
make destroy
```