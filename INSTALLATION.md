# 🚀 Guide d'Installation - Stack Observabilité

## 📋 Vue d'ensemble

Ce guide vous permet d'installer et de configurer la stack d'observabilité complète avec :
- **Application Flask** avec métriques Prometheus
- **Prometheus** pour la collecte de métriques
- **Grafana** pour la visualisation
- **Scripts de test** pour générer du trafic

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   App Server    │    │ Prometheus      │    │   Grafana       │
│   (Flask)       │    │ (Monitoring)    │    │ (Dashboard)     │
│                 │    │                 │    │                 │
│  - Flask App    │    │  - Prometheus   │    │  - Grafana      │
│  - /metrics     │◄──►│  - Port 9090    │◄──►│  - Port 3000    │
│  - Port 5000    │    │  - Scraping     │    │  - Dashboards   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📦 Fichiers Inclus

### Application Flask
- `app/flask_app.py` - Code source de l'application
- `app/requirements.txt` - Dépendances Python
- `app/flask-app.service` - Service systemd
- `app/README.md` - Documentation de l'application

### Configuration Prometheus
- `prometheus/prometheus.yml` - Configuration Prometheus
- `prometheus/README.md` - Documentation Prometheus

### Scripts de Test
- `scripts/quick_test.sh` - Test rapide
- `scripts/generate_traffic.sh` - Génération de trafic contrôlé
- `scripts/background_traffic.sh` - Trafic en arrière-plan
- `scripts/traffic_spike.sh` - Stress test
- `scripts/demo_observability.sh` - Démonstration interactive

## 🚀 Installation Rapide

### 1. Application Flask

```bash
# Installer Python et pip
sudo apt update
sudo apt install -y python3 python3-pip

# Installer les dépendances
cd app/
pip3 install -r requirements.txt

# Lancer l'application
python3 flask_app.py
```

### 2. Prometheus

```bash
# Télécharger et installer Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
sudo mv prometheus-2.45.0.linux-amd64 /opt/prometheus

# Copier la configuration
sudo cp prometheus/prometheus.yml /opt/prometheus/

# Créer l'utilisateur et démarrer
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /opt/prometheus
sudo systemctl start prometheus
```

### 3. Grafana

```bash
# Installer Grafana
sudo apt install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install -y grafana

# Démarrer Grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

## 🔧 Configuration

### 1. Configurer Prometheus pour scraper Flask

Modifier `prometheus.yml` :
```yaml
scrape_configs:
  - job_name: 'flask-app'
    static_configs:
      - targets: ['VOTRE_IP_FLASK:5000']  # Remplacer par votre IP
    metrics_path: '/metrics'
    scrape_interval: 5s
```

### 2. Configurer Grafana

1. Accéder à Grafana : `http://VOTRE_IP:3000`
2. Login : `admin` / `admin`
3. Ajouter datasource Prometheus : `http://VOTRE_IP_PROMETHEUS:9090`

## 🧪 Tests

### Test de base
```bash
# Tester l'application Flask
curl http://VOTRE_IP:5000/
curl http://VOTRE_IP:5000/metrics

# Tester Prometheus
curl http://VOTRE_IP:9090/api/v1/query?query=up

# Tester Grafana
curl -I http://VOTRE_IP:3000
```

### Scripts de test
```bash
# Rendre les scripts exécutables
chmod +x scripts/*.sh

# Test rapide
./scripts/quick_test.sh

# Génération de trafic
./scripts/generate_traffic.sh 100 60
```

## 📊 Métriques Disponibles

### Métriques Flask
```
flask_requests_total{method, endpoint, status}    # Compteur de requêtes
flask_errors_total{error_type}                    # Compteur d'erreurs
flask_error_rate                                  # Taux d'erreur (%)
flask_uptime_seconds                              # Temps de fonctionnement
flask_request_duration_seconds                    # Durée des requêtes
```

### Requêtes PromQL Utiles
```promql
# Taux de requêtes
sum(rate(flask_requests_total[5m]))

# Taux d'erreur
flask_error_rate

# Erreurs par type
sum by (error_type) (flask_errors_total)
```

## 🎯 URLs d'Accès

- **Application Flask** : `http://VOTRE_IP:5000`
- **Prometheus** : `http://VOTRE_IP:9090`
- **Grafana** : `http://VOTRE_IP:3000` (admin/admin)

## 🔍 Dépannage

### Vérifier les services
```bash
# Statut des services
sudo systemctl status flask-app
sudo systemctl status prometheus
sudo systemctl status grafana-server

# Logs
journalctl -u flask-app -f
journalctl -u prometheus -f
journalctl -u grafana-server -f
```

### Vérifier la connectivité
```bash
# Tester les ports
telnet VOTRE_IP 5000
telnet VOTRE_IP 9090
telnet VOTRE_IP 3000
```

## 📚 Documentation

- [Application Flask](app/README.md)
- [Configuration Prometheus](prometheus/README.md)
- [Scripts de Test](scripts/README.md)
- [Cours Magistral](Cours_Observabilite.md)
- [TP Pratique](TP.md)

## 🎉 Félicitations !

Votre stack d'observabilité est maintenant opérationnelle ! Vous pouvez :
- ✅ Visualiser les métriques dans Prometheus
- ✅ Créer des dashboards dans Grafana
- ✅ Générer du trafic avec les scripts
- ✅ Observer les métriques en temps réel

**Happy Monitoring !** 🚀
