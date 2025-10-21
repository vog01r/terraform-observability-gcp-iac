# 🎮 Guide Complet - TP Minecraft Observabilité

## 📋 Vue d'ensemble

Ce TP propose une approche ludique pour apprendre l'observabilité en monitorant un serveur Minecraft. Il combine **Terraform**, **Ansible**, **Prometheus** et **Grafana** dans un projet concret et amusant.

## 🎯 Objectifs Pédagogiques

- **Infrastructure as Code** avec Terraform
- **Configuration Management** avec Ansible  
- **Monitoring** avec Prometheus
- **Visualisation** avec Grafana
- **Métriques applicatives** et système
- **Dashboards** personnalisés

## 🏗️ Architecture

```
┌─────────────────────┐    ┌─────────────────────┐
│   Serveur Minecraft │    │  Serveur Monitoring │
│                     │    │                     │
│  - Minecraft Server │    │  - Prometheus       │
│  - Node Exporter    │    │  - Grafana          │
│  - Port 25565       │    │  - Ports 9090/3000  │
│                     │    │                     │
│  IP Publique        │    │  IP Publique        │
└─────────────────────┘    └─────────────────────┘
```

## 🚀 Déploiement Rapide

### Option 1 : Script Automatique
```bash
cd minecraft-tp
./scripts/deploy.sh
```

### Option 2 : Déploiement Manuel

#### 1. Configuration Terraform
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars avec votre project_id
terraform init
terraform apply
```

#### 2. Configuration Ansible
```bash
cd ../ansible
ansible-galaxy install -r requirements.yml
# Générer l'inventaire depuis les outputs Terraform
ansible-playbook -i inventory.yml playbook.yml
```

## 📊 Accès aux Services

### Serveur Minecraft
- **Connexion** : `minecraft://IP:25565`
- **SSH** : `ssh ubuntu@IP_MINECRAFT`

### Monitoring
- **Prometheus** : `http://IP_MONITORING:9090`
- **Grafana** : `http://IP_MONITORING:3000`
- **Login Grafana** : `admin` / `admin123`


## 📁 Structure du Projet

```
minecraft-tp/
├── terraform/                 # Infrastructure Terraform
│   ├── main.tf               # Configuration principale
│   ├── variables.tf          # Variables
│   ├── outputs.tf            # Outputs
│   ├── providers.tf          # Providers
│   └── terraform.tfvars.example
├── ansible/                   # Configuration Ansible
│   ├── playbook.yml          # Playbook principal
│   ├── inventory.yml         # Inventaire
│   └── requirements.yml      # Collections requises
├── scripts/                   # Scripts utilitaires
│   ├── deploy.sh             # Déploiement automatique
│   └── destroy.sh            # Destruction
└── README.md                  # Documentation
```

## 🛠️ Commandes Utiles

### Gestion Minecraft
```bash
# Statut du service
sudo systemctl status minecraft

# Redémarrage
sudo systemctl restart minecraft

# Logs
sudo journalctl -u minecraft -f
```

### Gestion Monitoring
```bash
# Statut des conteneurs
docker ps

# Logs Prometheus
docker logs prometheus

# Logs Grafana
docker logs grafana
```

## 📈 Métriques Disponibles

### Node Exporter
- CPU, RAM, Disque
- Réseau, Processus
- Système de fichiers

### Prometheus
- Métriques système en temps réel
- Historique des données
- Requêtes PromQL

### Grafana
- Dashboards prédéfinis
- Visualisations personnalisées
- Alertes configurables

## 🎮 Configuration Minecraft

### Paramètres du serveur
```bash
sudo vim /opt/minecraft/server.properties
```

### Plugins recommandés
- **Paper** (déjà installé)
- **Plugins de monitoring** (optionnels)

## 🔧 Personnalisation

### Configuration Prometheus
```bash
sudo vim /opt/monitoring/prometheus/prometheus.yml
```

### Dashboards Grafana
- Import de dashboards Node Exporter
- Création de dashboards personnalisés
- Configuration d'alertes

## 🐛 Dépannage

### Problèmes courants

1. **Minecraft ne démarre pas**
   ```bash
   sudo journalctl -u minecraft -f
   ```

2. **Prometheus ne collecte pas de métriques**
   ```bash
   curl http://IP_MINECRAFT:9100/metrics
   ```

3. **Grafana ne se connecte pas**
   ```bash
   docker logs grafana
   ```

## 🧹 Nettoyage

### Destruction complète
```bash
./scripts/destroy.sh
```

### Nettoyage manuel
```bash
cd terraform
terraform destroy
```

## 📚 Ressources

- [Documentation Terraform](https://terraform.io/docs)
- [Documentation Ansible](https://docs.ansible.com)
- [Documentation Prometheus](https://prometheus.io/docs)
- [Documentation Grafana](https://grafana.com/docs)
- [Paper Minecraft Server](https://papermc.io)

## 🎉 Conclusion

Ce TP offre une approche ludique et pratique pour apprendre l'observabilité. Les étudiants peuvent expérimenter avec les métriques, créer des dashboards personnalisés et comprendre l'importance du monitoring dans un environnement de production, le tout en s'amusant avec Minecraft !

---

**Note** : Ce TP est conçu pour être éducatif et ludique. Les métriques peuvent varier selon l'utilisation du serveur Minecraft.
