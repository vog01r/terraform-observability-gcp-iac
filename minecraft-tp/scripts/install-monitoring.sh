#!/bin/bash
# Script d'installation de Prometheus et Grafana
# Configuration complète pour le monitoring du serveur Minecraft

set -euo pipefail

echo "=== Installation de Prometheus et Grafana ==="

# Mise à jour du système
echo "Mise à jour du système..."
apt-get update
apt-get upgrade -y

# Installation des dépendances
echo "Installation des dépendances..."
apt-get install -y wget curl unzip

# Installation de Docker
echo "Installation de Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Installation de Docker Compose
echo "Installation de Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Création du répertoire de configuration
echo "Création des répertoires de configuration..."
mkdir -p /opt/monitoring/{prometheus,grafana/provisioning/{datasources,dashboards}}

# Configuration Prometheus
echo "Configuration de Prometheus..."
cat > /opt/monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'minecraft-monitor'

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 5s
    metrics_path: /metrics

  - job_name: 'minecraft-server'
    static_configs:
      - targets: ['10.0.1.3:9100']  # IP interne du serveur Minecraft
    scrape_interval: 10s
    metrics_path: /metrics
    scrape_timeout: 10s

  - job_name: 'monitoring-server'
    static_configs:
      - targets: ['localhost:9100']
    scrape_interval: 10s
    metrics_path: /metrics
EOF

# Création des règles d'alerte
mkdir -p /opt/monitoring/prometheus/rules
cat > /opt/monitoring/prometheus/rules/minecraft.yml << 'EOF'
groups:
  - name: minecraft
    rules:
      - alert: MinecraftServerDown
        expr: up{job="minecraft-server"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Serveur Minecraft indisponible"
          description: "Le serveur Minecraft n'est pas accessible depuis {{ $labels.instance }}"

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Utilisation CPU élevée"
          description: "L'utilisation CPU est de {{ $value }}% sur {{ $labels.instance }}"

      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Utilisation mémoire élevée"
          description: "L'utilisation mémoire est de {{ $value }}% sur {{ $labels.instance }}"

      - alert: DiskSpaceLow
        expr: (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Espace disque faible"
          description: "L'espace disque est à {{ $value }}% sur {{ $labels.instance }}"
EOF

# Configuration Grafana - Datasource
echo "Configuration de Grafana..."
cat > /opt/monitoring/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# Configuration Grafana - Dashboard
cat > /opt/monitoring/grafana/provisioning/dashboards/dashboard.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

# Création du dashboard Minecraft
mkdir -p /opt/monitoring/grafana/dashboards
cat > /opt/monitoring/grafana/dashboards/minecraft-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Minecraft Server Monitoring",
    "tags": ["minecraft"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "min": 0,
            "max": 100,
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 90}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "Memory Usage %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "min": 0,
            "max": 100,
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 85}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 0}
      },
      {
        "id": 3,
        "title": "Disk Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100",
            "legendFormat": "Disk Usage %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "min": 0,
            "max": 100,
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 80},
                {"color": "red", "value": 90}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 12, "y": 0}
      },
      {
        "id": 4,
        "title": "Network Traffic",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(node_network_receive_bytes_total[5m])",
            "legendFormat": "{{instance}} - Receive"
          },
          {
            "expr": "rate(node_network_transmit_bytes_total[5m])",
            "legendFormat": "{{instance}} - Transmit"
          }
        ],
        "yAxes": [
          {
            "label": "Bytes/sec",
            "unit": "Bps"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
EOF

# Configuration Docker Compose
echo "Configuration Docker Compose..."
cat > /opt/monitoring/docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    restart: unless-stopped
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/dashboards:/var/lib/grafana/dashboards
    restart: unless-stopped
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
EOF

# Démarrage des services
echo "Démarrage des services de monitoring..."
cd /opt/monitoring
docker-compose up -d

# Attendre que les services soient prêts
echo "Attente du démarrage des services..."
sleep 30

# Vérification du statut des services
echo "Vérification du statut des services..."
docker-compose ps

# Test de connectivité
echo "Test de connectivité..."
curl -f http://localhost:9090/api/v1/status/config || echo "Prometheus non accessible"
curl -f http://localhost:3000/api/health || echo "Grafana non accessible"

echo "=== Installation terminée avec succès! ==="
echo "Services disponibles:"
echo "- Prometheus: http://$(curl -s ifconfig.me):9090"
echo "- Grafana: http://$(curl -s ifconfig.me):3000 (admin/admin123)"
echo "- Node Exporter: http://$(curl -s ifconfig.me):9100"
echo ""
echo "Commandes utiles:"
echo "- Statut des services: docker-compose ps"
echo "- Logs Prometheus: docker-compose logs prometheus"
echo "- Logs Grafana: docker-compose logs grafana"
echo "- Redémarrage: docker-compose restart"
echo "- Arrêt: docker-compose down"
