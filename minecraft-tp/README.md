# TP Minecraft - Observabilité avec Prometheus et Grafana

## 🎮 Description du Projet

Ce TP ludique propose d'installer et de monitorer un serveur Minecraft en utilisant les technologies d'observabilité modernes. L'objectif est d'apprendre Terraform, Ansible, Prometheus et Grafana de manière pratique et amusante.

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

### Prérequis

1. **Google Cloud Platform** configuré
2. **Terraform** installé
3. **Ansible** installé
4. **Clés SSH** configurées

### 1. Configuration des variables

```bash
cd minecraft-tp/terraform
cp terraform.tfvars.example terraform.tfvars
```

Éditez `terraform.tfvars` :
```hcl
project_id = "votre-projet-gcp"
region     = "us-central1"
zone       = "us-central1-a"
machine_type = "e2-standard-2"
```

### 2. Déploiement Terraform

```bash
# Initialisation
terraform init

# Planification
terraform plan

# Déploiement
terraform apply
```

### 3. Configuration Ansible

```bash
cd ../ansible

# Installation des collections
ansible-galaxy install -r requirements.yml

# Génération de l'inventaire dynamique
terraform output -json > inventory.json

# Déploiement
ansible-playbook -i inventory.yml playbook.yml
```

## 🎯 Accès aux Services

### Serveur Minecraft
- **IP** : Voir `terraform output minecraft_server_ip`
- **Port** : 25565
- **Connexion** : `minecraft://IP:25565`

### Monitoring
- **Prometheus** : `http://IP_MONITORING:9090`
- **Grafana** : `http://IP_MONITORING:3000`
- **Login** : `admin` / `admin123`

## 📊 Métriques Disponibles

### Node Exporter (Serveur Minecraft)
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

## 🛠️ Commandes Utiles

### Gestion du serveur Minecraft
```bash
# Connexion SSH
ssh ubuntu@IP_MINECRAFT

# Statut du service
sudo systemctl status minecraft

# Redémarrage
sudo systemctl restart minecraft

# Logs
sudo journalctl -u minecraft -f
```

### Gestion du monitoring
```bash
# Connexion SSH
ssh ubuntu@IP_MONITORING

# Statut des conteneurs
docker ps

# Logs Prometheus
docker logs prometheus

# Logs Grafana
docker logs grafana
```

## 📈 Dashboards Grafana

### Dashboard Node Exporter
- **CPU Usage** : Utilisation processeur
- **Memory Usage** : Utilisation mémoire
- **Disk I/O** : Activité disque
- **Network Traffic** : Trafic réseau

### Dashboard Minecraft (Custom)
- **Server Status** : Statut du serveur
- **Player Count** : Nombre de joueurs
- **TPS** : Ticks par seconde
- **Memory Usage** : Mémoire Java

## 🔧 Personnalisation

### Configuration Minecraft
```bash
# Édition de la configuration
sudo vim /opt/minecraft/server.properties

# Redémarrage après modification
sudo systemctl restart minecraft
```

### Configuration Prometheus
```bash
# Édition de la configuration
sudo vim /opt/monitoring/prometheus/prometheus.yml

# Redémarrage
cd /opt/monitoring
docker-compose restart prometheus
```

## 🎓 Objectifs Pédagogiques

1. **Infrastructure as Code** avec Terraform
2. **Configuration Management** avec Ansible
3. **Monitoring** avec Prometheus
4. **Visualisation** avec Grafana
5. **Métriques applicatives** et système
6. **Dashboards** personnalisés

## 🐛 Dépannage

### Problèmes courants

1. **Minecraft ne démarre pas**
   ```bash
   sudo journalctl -u minecraft -f
   # Vérifier les logs Java
   ```

2. **Prometheus ne collecte pas de métriques**
   ```bash
   # Vérifier la connectivité
   curl http://IP_MINECRAFT:9100/metrics
   ```

3. **Grafana ne se connecte pas à Prometheus**
   ```bash
   # Vérifier la configuration
   docker logs grafana
   ```

## 📚 Ressources

- [Documentation Terraform](https://terraform.io/docs)
- [Documentation Ansible](https://docs.ansible.com)
- [Documentation Prometheus](https://prometheus.io/docs)
- [Documentation Grafana](https://grafana.com/docs)
- [Paper Minecraft Server](https://papermc.io)

## 🎉 Conclusion

Ce TP permet d'apprendre l'observabilité de manière ludique en monitorant un serveur Minecraft. Les étudiants peuvent expérimenter avec les métriques, créer des dashboards personnalisés et comprendre l'importance du monitoring dans un environnement de production.

---

**Note** : Ce TP est conçu pour être éducatif et ludique. Les métriques peuvent varier selon l'utilisation du serveur Minecraft.
