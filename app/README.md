# 🐍 Application Flask avec Métriques Prometheus

## 📋 Description

Application Flask instrumentée avec des métriques Prometheus pour démonstration d'observabilité. Cette application génère différents types d'erreurs et de trafic pour tester les capacités de monitoring.

## 🚀 Installation

### Prérequis
- Python 3.7+
- pip

### Installation des dépendances
```bash
pip install -r requirements.txt
```

### Lancement de l'application
```bash
python3 flask_app.py
```

L'application sera accessible sur `http://localhost:5000`

## 📊 Endpoints Disponibles

### Endpoints de Base
- **GET /** - Page d'accueil (5% d'erreurs aléatoires)
- **GET /health** - Health check (20% d'erreurs)
- **GET /stats** - Statistiques en temps réel
- **GET /metrics** - Métriques Prometheus

### Endpoints de Test
- **GET /error** - Génération d'erreurs manuelles
- **GET /slow** - Requêtes lentes (30% de timeout)

## 📈 Métriques Prometheus

### Métriques Exposées
```
flask_requests_total{method, endpoint, status}    # Compteur de requêtes
flask_errors_total{error_type}                    # Compteur d'erreurs
flask_error_rate                                  # Taux d'erreur (%)
flask_uptime_seconds                              # Temps de fonctionnement
flask_request_duration_seconds                    # Durée des requêtes
```

### Types d'Erreurs Générées
- **home_error** : Erreurs sur la page d'accueil (5%)
- **health_check_failed** : Échecs de health check (20%)
- **validation_error** : Erreurs de validation
- **database_error** : Erreurs de base de données
- **timeout_error** : Erreurs de timeout
- **permission_error** : Erreurs de permission
- **timeout** : Timeouts sur /slow (30%)

## 🔧 Configuration Systemd

### Installation du service
```bash
# Copier le fichier de service
sudo cp flask-app.service /etc/systemd/system/

# Recharger systemd
sudo systemctl daemon-reload

# Activer le service
sudo systemctl enable flask-app

# Démarrer le service
sudo systemctl start flask-app

# Vérifier le statut
sudo systemctl status flask-app
```

## 🧪 Tests

### Test de base
```bash
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/stats
```

### Test des métriques
```bash
curl http://localhost:5000/metrics
```

### Génération d'erreurs
```bash
curl http://localhost:5000/error
curl http://localhost:5000/slow
```

## 📊 Exemple de Réponse

### Endpoint /
```json
{
  "message": "Observability TP - Flask App with Prometheus",
  "status": "running",
  "timestamp": "2025-10-16T22:19:17.178265"
}
```

### Endpoint /stats
```json
{
  "uptime_seconds": 3600,
  "total_requests": 1250,
  "error_count": 125,
  "error_rate": 10.0,
  "timestamp": "2025-10-16T22:19:17.178265"
}
```

## 🔗 Intégration Prometheus

### Configuration Prometheus
Ajouter dans `prometheus.yml` :
```yaml
scrape_configs:
  - job_name: 'flask-app'
    static_configs:
      - targets: ['localhost:5000']
    metrics_path: '/metrics'
    scrape_interval: 5s
```

### Requêtes PromQL Utiles
```promql
# Taux de requêtes par seconde
sum(rate(flask_requests_total[5m]))

# Taux d'erreur
flask_error_rate

# Erreurs par type
sum by (error_type) (flask_errors_total)

# Temps de réponse (95e percentile)
histogram_quantile(0.95, rate(flask_request_duration_seconds_bucket[5m]))
```

## 🎯 Utilisation pour l'Observabilité

Cette application est conçue pour :
- ✅ Démontrer l'instrumentation Prometheus
- ✅ Générer des métriques réalistes
- ✅ Tester les capacités d'alerting
- ✅ Valider les dashboards Grafana
- ✅ Simuler des scénarios d'erreur

## 📝 Notes

- L'application génère des erreurs aléatoires pour simuler des conditions réelles
- Les métriques sont exposées au format Prometheus standard
- Compatible avec Grafana pour la visualisation
- Idéal pour les démonstrations et les TP d'observabilité
