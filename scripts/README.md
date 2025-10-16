# 🚀 Scripts de Test pour l'Observabilité

Ce dossier contient plusieurs scripts pour générer du trafic et des erreurs sur l'application Flask, permettant de faire bouger les graphiques dans Grafana et Prometheus.

## 📋 Scripts Disponibles

### 1. `generate_traffic.sh` - Génération de trafic contrôlée
**Usage:** `./generate_traffic.sh [nombre_requetes] [duree_secondes]`

Génère un nombre défini de requêtes sur une durée donnée.

**Exemples:**
```bash
./generate_traffic.sh                    # 100 requêtes sur 60 secondes
./generate_traffic.sh 50                 # 50 requêtes sur 60 secondes  
./generate_traffic.sh 200 120            # 200 requêtes sur 120 secondes
./generate_traffic.sh -s                 # Afficher les statistiques
./generate_traffic.sh -t                 # Tester la connectivité
```

### 2. `continuous_traffic.sh` - Trafic continu
**Usage:** `./continuous_traffic.sh [intensite]`

Génère du trafic en continu jusqu'à interruption (Ctrl+C).

**Intensités disponibles:**
- `low` : 2-5 secondes entre les requêtes
- `normal` : 0.5-2 secondes entre les requêtes (défaut)
- `high` : 0.1-0.5 secondes entre les requêtes

**Exemples:**
```bash
./continuous_traffic.sh                  # Mode normal
./continuous_traffic.sh high             # Mode rapide
./continuous_traffic.sh low              # Mode lent
```

### 3. `traffic_spike.sh` - Stress test avec pics de trafic
**Usage:** `./traffic_spike.sh [threads] [duree_secondes]`

Génère des pics de trafic intense avec plusieurs threads.

**Exemples:**
```bash
./traffic_spike.sh                       # 5 threads sur 30 secondes
./traffic_spike.sh 10 60                 # 10 threads sur 60 secondes
```

### 4. `background_traffic.sh` - Trafic en arrière-plan
**Usage:** `./background_traffic.sh [start|stop|status|logs]`

Gère un processus de trafic en arrière-plan.

**Commandes:**
```bash
./background_traffic.sh start            # Démarrer le trafic
./background_traffic.sh status           # Voir le statut
./background_traffic.sh logs             # Voir les logs
./background_traffic.sh stop             # Arrêter le trafic
```

### 5. `demo_observability.sh` - Démonstration interactive
**Usage:** `./demo_observability.sh`

Menu interactif pour lancer différents types de tests.

**Fonctionnalités:**
- Génération de trafic de base
- Pics d'erreurs
- Timeouts
- Trafic intense
- Démonstration complète
- Instructions Grafana

## 🎯 Types d'Erreurs Générées

L'application Flask génère plusieurs types d'erreurs :

- **Erreurs de santé** (`health_check_failed`) : 20% de chance sur `/health`
- **Erreurs de base de données** (`database_error`) : Via `/error`
- **Timeouts** (`timeout`) : 30% de chance sur `/slow`
- **Erreurs de validation** (`validation_error`) : Via `/error`
- **Erreurs de permission** (`permission_error`) : Via `/error`
- **Erreurs de timeout** (`timeout_error`) : Via `/error`

## 📊 Métriques Prometheus Disponibles

- `flask_requests_total` : Nombre total de requêtes par endpoint et statut
- `flask_errors_total` : Nombre d'erreurs par type
- `flask_error_rate` : Taux d'erreur en pourcentage
- `flask_uptime_seconds` : Temps de fonctionnement de l'application
- `flask_request_duration_seconds` : Durée des requêtes (histogramme)

## 🌐 URLs d'Accès

- **Application Flask** : http://34.69.67.242:5000
- **Prometheus** : http://35.224.152.222:9090
- **Grafana** : http://34.59.124.63:3000

## 🔍 Requêtes Prometheus Utiles pour Grafana

### Requêtes de base :
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

### Requêtes avancées :
```promql
# Taux d'erreur par endpoint
sum by (endpoint) (rate(flask_requests_total{status=~"5.."}[5m])) / sum by (endpoint) (rate(flask_requests_total[5m])) * 100

# Requêtes par minute
sum(increase(flask_requests_total[1m]))

# Erreurs par minute
sum(increase(flask_errors_total[1m]))
```

## 🚀 Démarrage Rapide

1. **Test simple :**
   ```bash
   ./generate_traffic.sh 50 30
   ```

2. **Trafic continu :**
   ```bash
   ./continuous_traffic.sh
   ```

3. **Démonstration complète :**
   ```bash
   ./demo_observability.sh
   ```

4. **Trafic en arrière-plan :**
   ```bash
   ./background_traffic.sh start
   ```

## 📈 Conseils pour Grafana

1. **Créez des graphiques en temps réel** avec un refresh de 5-10 secondes
2. **Utilisez des seuils d'alerte** pour le taux d'erreur (> 20%)
3. **Configurez des dashboards** avec plusieurs panels :
   - Graphique de ligne pour le taux de requêtes
   - Graphique de barres pour les erreurs par type
   - Gauge pour le taux d'erreur
   - Table pour les statistiques détaillées

4. **Lancez les scripts** pendant que vous regardez Grafana pour voir les graphiques évoluer en temps réel !

## 🛠️ Dépannage

- **Application non accessible** : Vérifiez que Flask est démarré avec `systemctl status flask-app`
- **Prometheus ne récupère pas les métriques** : Vérifiez la configuration dans `/etc/prometheus/prometheus.yml`
- **Grafana ne se connecte pas à Prometheus** : Vérifiez la datasource dans Grafana

## 📝 Logs

- **Trafic en arrière-plan** : `/tmp/background_traffic.log`
- **Application Flask** : `journalctl -u flask-app -f`
- **Prometheus** : `journalctl -u prometheus -f`
- **Grafana** : `journalctl -u grafana-server -f`
