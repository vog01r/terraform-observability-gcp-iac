# 📚 Cours Magistral : Observabilité et Monitoring Moderne

## 🎯 Plan du Cours

1. **Introduction à l'Observabilité**
2. **Les 3 Piliers : Métriques, Logs, Traces**
3. **Prometheus : Collecte et Stockage des Métriques**
4. **Grafana : Visualisation et Dashboards**
5. **Instrumentation d'Applications**
6. **Architecture et Bonnes Pratiques**
7. **TP Pratique : Stack Prometheus/Grafana**

---

## 📖 Chapitre 1 : Introduction à l'Observabilité

### 🔍 Qu'est-ce que l'Observabilité ?

**Définition :** Capacité à comprendre l'état interne d'un système à partir de ses sorties externes.

**Analogie :** Comme un médecin qui diagnostique un patient
- **Symptômes** = Métriques (fièvre, tension)
- **Antécédents** = Logs (historique médical)
- **Examens** = Traces (IRM, scanner)

### 🎯 Pourquoi l'Observabilité ?

**Problèmes traditionnels :**
- ❌ "Ça marche sur ma machine"
- ❌ "C'était qui qui a fait ce changement ?"
- ❌ "Pourquoi c'est lent ?"
- ❌ "Où est le problème ?"

**Solutions apportées :**
- ✅ Visibilité en temps réel
- ✅ Debugging proactif
- ✅ Détection d'anomalies
- ✅ Optimisation des performances

### 🏗️ Évolution du Monitoring

```
Monitoring Traditionnel → Observabilité Moderne
├─ Monolithique → Microservices
├─ Serveurs physiques → Cloud/Containers
├─ Monitoring réactif → Observabilité proactive
├─ Outils propriétaires → Open Source
└─ Métriques simples → Métriques + Logs + Traces
```

---

## 📊 Chapitre 2 : Les 3 Piliers de l'Observabilité

### 1. 📈 MÉTRIQUES (Metrics)

#### Définition
Valeurs numériques mesurées dans le temps, représentant l'état d'un système.

#### Types de Métriques

**Counter (Compteur)**
```promql
# Exemple : Nombre total de requêtes
flask_requests_total{method="GET", endpoint="/", status="200"} 1250
```
- ✅ Toujours croissant
- ✅ Utilisation : Taux, dérivées

**Gauge (Jauge)**
```promql
# Exemple : Utilisation CPU
cpu_usage_percent 45.3
```
- ✅ Peut augmenter ou diminuer
- ✅ Utilisation : Valeur instantanée

**Histogram (Histogramme)**
```promql
# Exemple : Durée des requêtes
flask_request_duration_seconds_bucket{le="0.1"} 100
flask_request_duration_seconds_bucket{le="0.5"} 500
flask_request_duration_seconds_bucket{le="1.0"} 800
```
- ✅ Distribution des valeurs
- ✅ Utilisation : Percentiles, moyennes

#### Caractéristiques
- **Volume** : Faible (milliers de points/seconde)
- **Stockage** : Long terme (mois/années)
- **Coût** : Faible
- **Alertes** : ✅ Excellent

### 2. 📝 LOGS

#### Définition
Événements discrets avec timestamp et contexte détaillé.

#### Types de Logs

**Structured Logs (Recommandé)**
```json
{
  "timestamp": "2024-01-15T10:30:45Z",
  "level": "ERROR",
  "message": "Database connection failed",
  "user_id": 12345,
  "request_id": "abc-123",
  "error": "timeout",
  "retry_count": 3
}
```

**Unstructured Logs**
```
2024-01-15 10:30:45 ERROR Database connection failed for user 12345
```

#### Caractéristiques
- **Volume** : Élevé (millions d'événements/seconde)
- **Stockage** : Court/moyen terme (jours/semaines)
- **Coût** : Élevé
- **Debug** : ✅ Excellent

### 3. 🔗 TRACES

#### Définition
Chemin d'exécution d'une requête à travers les services distribués.

#### Structure d'une Trace

```
Trace ID: abc123-def456
├─ Span: HTTP Request (10ms)
│  ├─ Span: Database Query (5ms)
│  │  └─ Span: Index Lookup (1ms)
│  └─ Span: Cache Lookup (2ms)
└─ Span: External API Call (8ms)
   └─ Span: Network Roundtrip (7ms)
```

#### Caractéristiques
- **Volume** : Moyen (milliers de traces/seconde)
- **Stockage** : Court terme (heures/jours)
- **Coût** : Moyen
- **Performance** : ✅ Excellent

### 🎯 Comparaison des 3 Piliers

| Aspect | Métriques | Logs | Traces |
|--------|-----------|------|--------|
| **Question** | "Combien ?" | "Quoi ?" | "Comment ?" |
| **Volume** | Faible | Élevé | Moyen |
| **Stockage** | Long terme | Court terme | Très court terme |
| **Alertes** | ✅ | ❌ | ❌ |
| **Debug** | ❌ | ✅ | ✅ |
| **Performance** | ❌ | ❌ | ✅ |

---

## 🔧 Chapitre 3 : Prometheus - Collecte et Stockage

### 🎯 Qu'est-ce que Prometheus ?

**Définition :** Système de monitoring et d'alerting open source, spécialisé dans les métriques.

**Caractéristiques :**
- ✅ Pull-based (va chercher les métriques)
- ✅ Time-series database
- ✅ PromQL (langage de requête)
- ✅ Service discovery automatique
- ✅ Alerting intégré

### 🏗️ Architecture Prometheus

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Applications  │    │   Prometheus    │    │   Alertmanager  │
│                 │    │                 │    │                 │
│  - /metrics     │◄──►│  - Scraping     │    │  - Alerting     │
│  - Exporter     │    │  - Storage      │    │  - Routing      │
│  - Pushgateway  │    │  - PromQL       │    │  - Notifications│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 📊 Modèle de Données

#### Métriques et Labels
```promql
# Format : metric_name{label1="value1", label2="value2"} value timestamp
flask_requests_total{method="GET", endpoint="/", status="200"} 1250 1642248000000
flask_requests_total{method="GET", endpoint="/", status="500"} 25 1642248000000
flask_requests_total{method="POST", endpoint="/api", status="200"} 500 1642248000000
```

#### Types de Métriques Prometheus

**Counter**
```promql
# Toujours croissant
http_requests_total{method="GET"} 1000
http_requests_total{method="POST"} 200
```

**Gauge**
```promql
# Peut varier
memory_usage_bytes 1024000000
cpu_usage_percent 45.3
```

**Histogram**
```promql
# Distribution avec buckets
http_request_duration_seconds_bucket{le="0.1"} 100
http_request_duration_seconds_bucket{le="0.5"} 500
http_request_duration_seconds_bucket{le="1.0"} 800
http_request_duration_seconds_bucket{le="+Inf"} 1000
http_request_duration_seconds_sum 450.5
http_request_duration_seconds_count 1000
```

**Summary**
```promql
# Percentiles pré-calculés
http_request_duration_seconds{quantile="0.5"} 0.2
http_request_duration_seconds{quantile="0.9"} 0.8
http_request_duration_seconds{quantile="0.99"} 1.5
http_request_duration_seconds_sum 450.5
http_request_duration_seconds_count 1000
```

### 🔍 PromQL - Langage de Requête

#### Requêtes de Base
```promql
# Valeur instantanée
flask_requests_total

# Filtrage par labels
flask_requests_total{status="200"}

# Agrégation
sum(flask_requests_total)

# Groupement
sum by (status) (flask_requests_total)
```

#### Fonctions Temporelles
```promql
# Taux de changement
rate(flask_requests_total[5m])

# Augmentation
increase(flask_requests_total[1h])

# Moyenne mobile
avg_over_time(cpu_usage_percent[5m])
```

#### Fonctions Mathématiques
```promql
# Pourcentages
(flask_errors_total / flask_requests_total) * 100

# Percentiles (histogram)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Agrégations
max(flask_requests_total)
min(flask_requests_total)
avg(flask_requests_total)
```

### ⚙️ Configuration Prometheus

#### prometheus.yml
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'flask-app'
    static_configs:
      - targets: ['app-server:5000']
    metrics_path: '/metrics'
    scrape_interval: 10s
```

---

## 📊 Chapitre 4 : Grafana - Visualisation

### 🎯 Qu'est-ce que Grafana ?

**Définition :** Plateforme de visualisation et d'analyse de données, spécialisée dans les métriques.

**Caractéristiques :**
- ✅ Dashboards interactifs
- ✅ Multiples datasources
- ✅ Alerting avancé
- ✅ Plugins et extensions
- ✅ Collaboration d'équipe

### 🏗️ Architecture Grafana

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Dashboards    │    │     Grafana     │    │  Data Sources   │
│                 │    │                 │    │                 │
│  - Panels       │◄──►│  - UI/API       │◄──►│  - Prometheus   │
│  - Variables    │    │  - Auth         │    │  - InfluxDB     │
│  - Annotations  │    │  - Plugins      │    │  - MySQL        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 📈 Types de Panels

#### Graph Panel
```promql
# Requête simple
flask_requests_total

# Requête avec fonction
rate(flask_requests_total[5m])
```

#### Stat Panel
```promql
# Valeur unique
flask_error_rate

# Avec seuils
flask_uptime_seconds
```

#### Gauge Panel
```promql
# Pourcentage
(flask_errors_total / flask_requests_total) * 100
```

#### Bar Chart Panel
```promql
# Répartition par status
sum by (status) (flask_requests_total)
```

#### Heatmap Panel
```promql
# Distribution des durées
rate(flask_request_duration_seconds_bucket[5m])
```

### 🎨 Bonnes Pratiques de Dashboard

#### Structure d'un Dashboard
```
📊 Dashboard: Application Monitoring
├─ 📈 Row: Overview
│  ├─ Stat: Total Requests
│  ├─ Stat: Error Rate
│  └─ Stat: Uptime
├─ 📈 Row: Performance
│  ├─ Graph: Request Rate
│  ├─ Graph: Response Time
│  └─ Heatmap: Duration Distribution
└─ 📈 Row: Errors
   ├─ Graph: Error Rate
   └─ Bar Chart: Errors by Type
```

#### Variables de Dashboard
```yaml
# Variable: instance
Name: instance
Type: query
Query: label_values(flask_requests_total, instance)

# Variable: time_range
Name: time_range
Type: interval
Values: 5m,15m,1h,6h,12h,1d
```

#### Alerting dans Grafana
```yaml
# Règle d'alerte
Name: High Error Rate
Query: (flask_errors_total / flask_requests_total) * 100
Condition: IS ABOVE 5
Evaluation: 5m
```

---

## 🐍 Chapitre 5 : Instrumentation d'Applications

### 🎯 Qu'est-ce que l'Instrumentation ?

**Définition :** Ajout de code de monitoring dans une application pour exposer des métriques.

**Types d'instrumentation :**
- ✅ **Automatic** : Framework gère tout
- ✅ **Manual** : Développeur ajoute le code
- ✅ **Hybrid** : Combinaison des deux

### 🐍 Instrumentation Python/Flask

#### Installation
```bash
pip install prometheus_client
```

#### Métriques de Base
```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest

# Counter - toujours croissant
REQUEST_COUNT = Counter('flask_requests_total', 'Total requests', ['method', 'endpoint', 'status'])

# Gauge - peut varier
ERROR_RATE = Gauge('flask_error_rate', 'Error rate percentage')

# Histogram - distribution
REQUEST_DURATION = Histogram('flask_request_duration_seconds', 'Request duration')

@app.route('/')
def home():
    with REQUEST_DURATION.time():
        # Logique métier
        REQUEST_COUNT.labels(method='GET', endpoint='/', status='200').inc()
        return "Hello World"
```

#### Endpoint /metrics
```python
@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain'}
```

### 🔧 Bonnes Pratiques d'Instrumentation

#### Métriques Recommandées
```python
# Métriques d'application
app_requests_total = Counter('app_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
app_request_duration = Histogram('app_request_duration_seconds', 'Request duration')
app_errors_total = Counter('app_errors_total', 'Total errors', ['error_type'])
app_active_connections = Gauge('app_active_connections', 'Active connections')

# Métriques métier
user_registrations_total = Counter('user_registrations_total', 'User registrations')
payment_processing_duration = Histogram('payment_processing_seconds', 'Payment processing time')
```

#### Labels Appropriés
```python
# ✅ Bon - Labels avec cardinalité limitée
REQUEST_COUNT.labels(method='GET', status='200').inc()

# ❌ Mauvais - Labels avec cardinalité élevée
REQUEST_COUNT.labels(user_id='12345', session_id='abc123').inc()
```

#### Gestion des Erreurs
```python
@app.route('/api/data')
def get_data():
    try:
        # Logique métier
        data = fetch_data()
        REQUEST_COUNT.labels(method='GET', endpoint='/api/data', status='200').inc()
        return jsonify(data)
    except DatabaseError as e:
        REQUEST_COUNT.labels(method='GET', endpoint='/api/data', status='500').inc()
        ERROR_COUNT.labels(error_type='database_error').inc()
        raise
```

---

## 🏗️ Chapitre 6 : Architecture et Bonnes Pratiques

### 🎯 Architecture de Monitoring

#### Architecture Centralisée
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Applications  │    │   Prometheus    │    │     Grafana     │
│                 │    │                 │    │                 │
│  - /metrics     │◄──►│  - Scraping     │◄──►│  - Dashboards   │
│  - Exporters    │    │  - Storage      │    │  - Alerting     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### Architecture Distribuée
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Prometheus    │    │   Prometheus    │    │   Prometheus    │
│   (Region A)    │    │   (Region B)    │    │   (Region C)    │
│                 │    │                 │    │                 │
│  - Scraping     │    │  - Scraping     │    │  - Scraping     │
│  - Storage      │    │  - Storage      │    │  - Storage      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Grafana       │
                    │   (Global)      │
                    │                 │
                    │  - Federation   │
                    │  - Dashboards   │
                    └─────────────────┘
```

### 📊 Stratégies de Collecte

#### Pull vs Push
```yaml
# Pull (Prometheus standard)
scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:5000']

# Push (Pushgateway)
# Pour jobs batch ou services éphémères
```

#### Service Discovery
```yaml
# Découverte automatique
scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

### 🚨 Stratégies d'Alerting

#### Hiérarchie des Alertes
```
🔴 Critical (P0)
├─ Service down
├─ High error rate (>5%)
└─ Security breach

🟡 Warning (P1)
├─ High latency (>1s)
├─ Low disk space (<10%)
└─ High CPU usage (>80%)

🟢 Info (P2)
├─ Deployment completed
├─ New version released
└─ Maintenance scheduled
```

#### Règles d'Alerte Prometheus
```yaml
groups:
  - name: flask.rules
    rules:
      - alert: HighErrorRate
        expr: (flask_errors_total / flask_requests_total) * 100 > 5
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}% for {{ $labels.instance }}"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} is not responding"
```

### 📈 Métriques SRE (Site Reliability Engineering)

#### Les 4 Golden Signals
```promql
# 1. Latency - Temps de réponse
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# 2. Traffic - Volume de requêtes
rate(http_requests_total[5m])

# 3. Errors - Taux d'erreur
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# 4. Saturation - Utilisation des ressources
cpu_usage_percent
memory_usage_percent
```

#### SLI/SLO/SLA
```yaml
# SLI (Service Level Indicator)
availability: 99.9%
latency_p99: 200ms
error_rate: 0.1%

# SLO (Service Level Objective)
availability: 99.9% (3.6 minutes downtime/month)
latency_p99: 200ms
error_rate: 0.1%

# SLA (Service Level Agreement)
availability: 99.9% (avec compensation si non respecté)
```

---

## 🛠️ Chapitre 7 : TP Pratique - Stack Prometheus/Grafana

### 🎯 Objectifs du TP

1. **Déployer** une stack de monitoring complète
2. **Instrumenter** une application Flask
3. **Configurer** Prometheus pour la collecte
4. **Créer** des dashboards Grafana
5. **Tester** avec des scripts de charge

### 🏗️ Architecture du TP

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   App Server    │    │ Prometheus      │    │   Grafana       │
│   (Flask)       │    │ (Monitoring)    │    │ (Dashboard)     │
│                 │    │                 │    │                 │
│  - Flask App    │    │  - Prometheus   │    │  - Grafana      │
│  - /metrics     │◄──►│  - Scraping     │◄──►│  - Dashboards   │
│  - Port 5000    │    │  - Port 9090    │    │  - Port 3000    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 📊 Métriques Implémentées

#### Métriques Flask
```python
# Compteurs
REQUEST_COUNT = Counter('flask_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
ERROR_COUNT = Counter('flask_errors_total', 'Total errors', ['error_type'])

# Jauges
ERROR_RATE_GAUGE = Gauge('flask_error_rate', 'Error rate percentage')
UPTIME_GAUGE = Gauge('flask_uptime_seconds', 'Application uptime')

# Histogrammes
REQUEST_DURATION = Histogram('flask_request_duration_seconds', 'Request duration')
```

#### Endpoints de Test
```python
@app.route('/')           # Page d'accueil (5% d'erreurs)
@app.route('/health')     # Health check (20% d'erreurs)
@app.route('/stats')      # Statistiques
@app.route('/error')      # Génération d'erreurs
@app.route('/slow')       # Requêtes lentes (30% timeout)
@app.route('/metrics')    # Métriques Prometheus
```

### 🧪 Scripts de Test

#### Scripts Disponibles
```bash
# Test rapide
./scripts/quick_test.sh

# Trafic contrôlé
./scripts/generate_traffic.sh 100 60

# Trafic en arrière-plan
./scripts/background_traffic.sh start

# Stress test
./scripts/traffic_spike.sh 10 30

# Démonstration interactive
./scripts/demo_observability.sh
```

### 📈 Dashboards Grafana

#### Dashboard Principal
```
📊 Flask Application Monitoring
├─ 📈 Overview
│  ├─ Stat: Total Requests
│  ├─ Stat: Error Rate
│  └─ Stat: Uptime
├─ 📈 Performance
│  ├─ Graph: Request Rate (req/s)
│  ├─ Graph: Response Time (p95)
│  └─ Heatmap: Duration Distribution
└─ 📈 Errors
   ├─ Graph: Error Rate Over Time
   └─ Bar Chart: Errors by Type
```

#### Requêtes PromQL Utilisées
```promql
# Taux de requêtes
sum(rate(flask_requests_total[5m]))

# Taux d'erreur
flask_error_rate

# Temps de réponse (95e percentile)
histogram_quantile(0.95, rate(flask_request_duration_seconds_bucket[5m]))

# Erreurs par type
sum by (error_type) (flask_errors_total)
```

---

## 🎓 Conclusion

### 🎯 Points Clés à Retenir

1. **Observabilité = 3 Piliers**
   - Métriques (combien)
   - Logs (quoi)
   - Traces (comment)

2. **Prometheus = Métriques**
   - Pull-based
   - Time-series database
   - PromQL

3. **Grafana = Visualisation**
   - Dashboards interactifs
   - Multi-datasources
   - Alerting

4. **Instrumentation = Code**
   - Ajout de métriques dans l'app
   - Endpoint /metrics
   - Bonnes pratiques

### 🚀 Prochaines Étapes

1. **Logs** : ELK Stack (Elasticsearch + Logstash + Kibana)
2. **Traces** : Jaeger ou Zipkin
3. **Alerting** : Alertmanager + PagerDuty
4. **Service Discovery** : Kubernetes, Consul
5. **Federation** : Prometheus multi-régions

### 📚 Ressources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Python Client](https://github.com/prometheus/client_python)
- [SRE Book](https://sre.google/sre-book/table-of-contents/)

---

## ❓ Questions & Réponses

### Q: Pourquoi Prometheus plutôt que d'autres solutions ?
**R:** Prometheus est open source, performant, avec un écosystème riche et PromQL puissant.

### Q: Comment gérer la cardinalité des métriques ?
**R:** Limiter les labels à des valeurs avec cardinalité faible (status, method) et éviter les IDs utilisateur.

### Q: Quand utiliser Push vs Pull ?
**R:** Pull pour les services long-running, Push (Pushgateway) pour les jobs batch.

### Q: Comment optimiser les performances de Grafana ?
**R:** Limiter les requêtes complexes, utiliser des intervalles appropriés, optimiser les dashboards.

### Q: Quelle est la différence entre Histogram et Summary ?
**R:** Histogram = buckets côté client, Summary = percentiles côté client. Histogram plus flexible.

---

**🎉 Fin du Cours Magistral sur l'Observabilité !**

*Ce cours couvre les concepts fondamentaux de l'observabilité moderne avec un focus pratique sur Prometheus et Grafana. Les étudiants peuvent maintenant appliquer ces connaissances dans le TP pratique.*
