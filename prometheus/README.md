# 📊 Configuration Prometheus

## 📋 Description

Configuration Prometheus pour le monitoring de l'application Flask et des services associés.

## 🔧 Configuration

### Fichier prometheus.yml

Le fichier `prometheus.yml` contient la configuration pour :

#### Jobs de Scraping
- **prometheus** : Monitoring de Prometheus lui-même
- **flask-app** : Application Flask avec métriques
- **node-exporter** : Métriques système (si installé)

### Configuration des Targets

```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'flask-app'
    static_configs:
      - targets: ['10.42.0.3:5000']  # IP de l'application Flask
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['10.42.0.3:9100', '10.42.0.4:9100', '10.42.0.2:9100']
```

## 🚀 Installation

### Installation de Prometheus
```bash
# Télécharger Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
sudo mv prometheus-2.45.0.linux-amd64 /opt/prometheus

# Copier la configuration
sudo cp prometheus.yml /opt/prometheus/

# Créer l'utilisateur prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /opt/prometheus
```

### Service Systemd
```bash
# Créer le fichier de service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \\
    --config.file /opt/prometheus/prometheus.yml \\
    --storage.tsdb.path /opt/prometheus/data \\
    --web.console.templates=/opt/prometheus/consoles \\
    --web.console.libraries=/opt/prometheus/console_libraries \\
    --web.listen-address=0.0.0.0:9090 \\
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Activer et démarrer le service
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

## 🔍 Vérification

### Vérifier le statut
```bash
sudo systemctl status prometheus
```

### Vérifier les targets
```bash
curl http://localhost:9090/api/v1/targets
```

### Interface web
```
http://PROMETHEUS_IP:9090
```

## 📊 Métriques Collectées

### Application Flask
- `flask_requests_total` - Nombre total de requêtes
- `flask_errors_total` - Nombre d'erreurs par type
- `flask_error_rate` - Taux d'erreur
- `flask_uptime_seconds` - Temps de fonctionnement
- `flask_request_duration_seconds` - Durée des requêtes

### Prometheus
- `prometheus_*` - Métriques internes de Prometheus

### Node Exporter (si installé)
- `node_*` - Métriques système (CPU, mémoire, disque, réseau)

## 🎯 Requêtes PromQL Utiles

### Requêtes de Base
```promql
# Vérifier que les services sont UP
up

# Taux de requêtes Flask
sum(rate(flask_requests_total[5m]))

# Taux d'erreur Flask
flask_error_rate

# Erreurs par type
sum by (error_type) (flask_errors_total)
```

### Requêtes Avancées
```promql
# Temps de réponse (95e percentile)
histogram_quantile(0.95, rate(flask_request_duration_seconds_bucket[5m]))

# Requêtes par endpoint
sum by (endpoint) (rate(flask_requests_total[5m]))

# Erreurs par status HTTP
sum by (status) (rate(flask_requests_total{status=~"5.."}[5m]))
```

## 🔧 Personnalisation

### Ajouter de nouveaux targets
```yaml
scrape_configs:
  - job_name: 'new-service'
    static_configs:
      - targets: ['new-service:8080']
    metrics_path: '/metrics'
    scrape_interval: 15s
```

### Modifier les intervalles
```yaml
global:
  scrape_interval: 10s      # Fréquence de scraping
  evaluation_interval: 10s  # Fréquence d'évaluation des règles
```

## 🚨 Alerting (Optionnel)

### Règles d'alerte
```yaml
# alert_rules.yml
groups:
  - name: flask.rules
    rules:
      - alert: HighErrorRate
        expr: flask_error_rate > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}%"
```

## 📝 Notes

- La configuration est optimisée pour le TP d'observabilité
- Les intervalles de scraping sont courts pour une démonstration en temps réel
- Compatible avec Grafana pour la visualisation
- Prêt pour l'ajout d'alertes et de règles personnalisées
