# TP Minecraft - Observabilité

Ce projet déploie une infrastructure complète sur Google Cloud Platform avec :
- Un serveur Minecraft utilisant LinuxGSM
- Un serveur de monitoring avec Prometheus et Grafana
- Configuration automatique des métriques et alertes

## 🏗️ Architecture

```
┌─────────────────────┐    ┌─────────────────────┐
│   Serveur Minecraft │    │  Serveur Monitoring │
│                     │    │                     │
│  - LinuxGSM         │    │  - Prometheus       │
│  - Node Exporter    │◄───┤  - Grafana          │
│  - Port 25565       │    │  - Node Exporter    │
│  - Port 9100        │    │  - Port 9090        │
│                     │    │  - Port 3000        │
└─────────────────────┘    └─────────────────────┘
```

## 📋 Prérequis

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
- Clé SSH générée (`ssh-keygen -t rsa`)
- Compte Google Cloud avec facturation activée

## 🚀 Déploiement rapide

### 1. Configuration initiale

```bash
# Cloner le projet
git clone <votre-repo>
cd minecraft-tp

# Authentification Google Cloud
gcloud auth login
gcloud auth application-default login

# Configuration du projet
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Modifiez terraform.tfvars avec votre project_id
```

### 2. Déploiement automatique

```bash
# Déploiement complet avec tests
./scripts/deploy.sh
```

### 3. Déploiement manuel

```bash
# Initialisation
cd terraform
terraform init

# Planification
terraform plan

# Déploiement
terraform apply
```

## 🎮 Utilisation

### Serveur Minecraft

Le serveur Minecraft est installé avec LinuxGSM et accessible sur le port 25565.

**Commandes LinuxGSM disponibles :**
```bash
# Se connecter au serveur
ssh -i ~/.ssh/id_rsa ubuntu@<IP_MINCRAFT>

# Passer à l'utilisateur mcserver
su - mcserver

# Commandes LinuxGSM
./mcserver start          # Démarrer le serveur
./mcserver stop           # Arrêter le serveur
./mcserver restart        # Redémarrer le serveur
./mcserver console        # Console en temps réel
./mcserver update         # Mettre à jour le serveur
./mcserver backup         # Créer une sauvegarde
./mcserver monitor        # Vérifier le statut
./mcserver details        # Informations détaillées
```

**Informations de connexion :**
- Utilisateur : `mcserver`
- Mot de passe : `jE5Mzg1NDc3M`
- Port : `25565`

### Monitoring

#### Prometheus
- URL : `http://<IP_MONITORING>:9090`
- Métriques système et serveur Minecraft
- Alertes configurées pour CPU, mémoire, disque

#### Grafana
- URL : `http://<IP_MONITORING>:3000`
- Utilisateur : `admin`
- Mot de passe : `admin123`
- Dashboard Minecraft pré-configuré

## 🧪 Tests

```bash
# Test complet du déploiement
./scripts/test-deployment.sh

# Tests manuels
# Test Minecraft
nc -zv <IP_MINCRAFT> 25565

# Test Prometheus
curl http://<IP_MONITORING>:9090/api/v1/status/config

# Test Grafana
curl http://<IP_MONITORING>:3000/api/health
```

## 📊 Métriques disponibles

### Métriques système (Node Exporter)
- CPU usage
- Memory usage
- Disk usage
- Network traffic
- Load average

### Métriques Minecraft
- Serveur up/down
- Nombre de joueurs connectés
- Performance du serveur

## 🔧 Configuration

### Variables Terraform

| Variable | Description | Défaut |
|----------|-------------|---------|
| `project_id` | ID du projet GCP | Obligatoire |
| `region` | Région GCP | `us-central1` |
| `zone` | Zone GCP | `us-central1-a` |
| `machine_type` | Type de machine | `e2-standard-2` |
| `ssh_user` | Utilisateur SSH | `ubuntu` |
| `ssh_public_key_path` | Chemin clé SSH | `~/.ssh/id_rsa.pub` |

### Personnalisation

#### Modifier la version Minecraft
Éditez `scripts/install-minecraft-linuxgsm.sh` :
```bash
# Changer la version Paper
wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/1300/downloads/paper-1.20.4-1300.jar
```

#### Ajouter des métriques personnalisées
Éditez `scripts/install-monitoring.sh` :
```yaml
# Ajouter des targets Prometheus
- job_name: 'custom-metrics'
  static_configs:
    - targets: ['custom-server:9100']
```

## 🗑️ Nettoyage

```bash
# Supprimer l'infrastructure
cd terraform
terraform destroy

# Confirmer la suppression
yes
```

## 📝 Logs et débogage

### Logs des services
```bash
# Logs LinuxGSM
journalctl -u minecraft -f

# Logs Node Exporter
journalctl -u node_exporter -f

# Logs Docker (monitoring)
docker-compose logs -f
```

### Débogage
```bash
# Statut des services
systemctl status minecraft
systemctl status node_exporter

# Test de connectivité
./mcserver debug
```

## 🔒 Sécurité

- Firewall configuré pour les ports nécessaires uniquement
- Service Accounts avec permissions minimales
- Communication interne sécurisée
- Mots de passe par défaut à changer en production

## 📚 Ressources

- [LinuxGSM Documentation](https://docs.linuxgsm.com/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## 🆘 Support

En cas de problème :
1. Vérifiez les logs des services
2. Testez la connectivité réseau
3. Vérifiez les permissions GCP
4. Consultez la documentation des outils

## 📄 Licence

Ce projet est fourni à des fins éducatives dans le cadre du TP Minecraft - Observabilité.