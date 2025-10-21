# TP Observabilité - Stack de Monitoring Moderne

## 📋 Informations Générales

- **Durée estimée** : 8 heures
- **Niveau** : Intermédiaire
- **Technologies** : Prometheus, Grafana, Flask, Python, Cloud Provider
- **Objectif** : Déployer et configurer une infrastructure d'observabilité moderne avec Prometheus et Grafana

## 🎯 Objectifs Pédagogiques

À la fin de ce TP, vous serez capable de :

1. **Monitoring Moderne** : Mettre en place Prometheus pour la collecte de métriques
2. **Visualisation** : Configurer Grafana pour les tableaux de bord
3. **Métriques d'Application** : Instrumenter une application Flask avec Prometheus
4. **Intégration** : Connecter tous les composants pour un monitoring complet
5. **Tests de Charge** : Utiliser des scripts pour générer du trafic et valider l'observabilité

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   App Server    │    │ Prometheus      │    │   Grafana       │
│   (Flask)       │    │ (Monitoring)    │    │ (Dashboard)     │
│                 │    │                 │    │                 │
│  - Flask App    │    │  - Prometheus   │    │  - Grafana      │
│  - Prometheus   │◄──►│  - Port 9090    │◄──►│  - Prometheus   │
│  - Port 5000    │    │  - Scraping     │    │  - Port 3000    │
│  - /metrics     │    │  - Storage      │    │  - Dashboards   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Network       │
                    │   (Cloud/Local) │
                    └─────────────────┘
```

## 📚 Prérequis

### Logiciels Requis
- **Python 3** (pour l'application Flask et les scripts de test)
- **Prometheus** (pour la collecte de métriques)
- **Grafana** (pour la visualisation)
- **Git** (pour récupérer le code)
- **Accès réseau** aux serveurs (Cloud ou local)

### Environnement
- 3 serveurs ou machines virtuelles accessibles
- Connexion réseau entre les composants
- Ports ouverts : 5000 (Flask), 9090 (Prometheus), 3000 (Grafana)
- Accès SSH ou console aux serveurs

## 🚀 Étapes du TP

### Étape 1 : Préparation de l'Environnement (30 min)

#### 1.1 Configuration du Projet
```bash
# Cloner le projet
git clone <REPO_URL>
cd observability
```

#### 1.2 Configuration des Adresses IP
Notez les adresses IP de vos serveurs :
- **App Server** : `APP_IP` (Flask sur port 5000)
- **Prometheus Server** : `PROMETHEUS_IP` (Prometheus sur port 9090)
- **Grafana Server** : `GRAFANA_IP` (Grafana sur port 3000)

#### 1.3 Vérification de la Connectivité
```bash
# Tester l'accès aux serveurs
ping APP_IP
ping PROMETHEUS_IP
ping GRAFANA_IP

# Vérifier les ports
telnet APP_IP 5000
telnet PROMETHEUS_IP 9090
telnet GRAFANA_IP 3000
```

### Étape 2 : Installation des Services (1h)

#### 2.1 Installation de l'Application Flask
Sur le serveur App :
```bash
# Installer Python et les dépendances
sudo apt update
sudo apt install -y python3 python3-pip

# Installer Flask et Prometheus client
pip3 install flask prometheus_client

# Déployer l'application
# (Le code de l'application sera fourni)
```

#### 2.2 Installation de Prometheus
Sur le serveur Prometheus :
```bash
# Télécharger et installer Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
sudo mv prometheus-2.45.0.linux-amd64 /opt/prometheus

# Configurer Prometheus
# (La configuration sera fournie)
```

#### 2.3 Installation de Grafana
Sur le serveur Grafana :
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

### Étape 3 : Configuration et Vérification (30 min)

#### 3.1 Configuration des Services
```bash
# Configurer Prometheus pour scraper Flask
# (Modifier le fichier de configuration Prometheus)

# Configurer Grafana pour se connecter à Prometheus
# (Ajouter la datasource Prometheus)
```

#### 3.2 Vérification des Services
```bash
# Vérifier Flask
curl http://APP_IP:5000/health
curl http://APP_IP:5000/metrics

# Vérifier Prometheus
curl http://PROMETHEUS_IP:9090/api/v1/query?query=up

# Vérifier Grafana
curl -I http://GRAFANA_IP:3000
```

**Services à vérifier :**
1. Flask App avec métriques Prometheus exposées
2. Prometheus Server collectant les métriques
3. Grafana connecté à Prometheus

### Étape 4 : Validation et Tests (1h)

#### 4.1 Test de l'Application Flask
```bash
# Test des endpoints
curl http://APP_IP:5000/
curl http://APP_IP:5000/health
curl http://APP_IP:5000/stats
curl http://APP_IP:5000/error
curl http://APP_IP:5000/slow

# Vérifier les métriques Prometheus
curl http://APP_IP:5000/metrics
```

#### 4.2 Accès aux Interfaces Web

**Prometheus (http://PROMETHEUS_IP:9090)**
- Interface web Prometheus
- Vérifier les targets dans Status → Targets
- Consulter les métriques dans Graph

**Grafana (http://GRAFANA_IP:3000)**
- Utilisateur : `admin`
- Mot de passe : `admin`
- Vérifier la datasource Prometheus
- Explorer les métriques Flask

### Étape 5 : Exploration et Personnalisation (2h)

#### 5.1 Exploration des Métriques Prometheus
1. **Métriques Disponibles**
   - `flask_requests_total` : Nombre total de requêtes par endpoint et statut
   - `flask_errors_total` : Erreurs par type (health_check_failed, database_error, timeout_error, etc.)
   - `flask_error_rate` : Taux d'erreur en pourcentage
   - `flask_uptime_seconds` : Temps de fonctionnement de l'application
   - `flask_request_duration_seconds` : Durée des requêtes (histogramme)

2. **Types d'Erreurs Générées**
   - **Erreurs de santé** : 20% de chance sur `/health`
   - **Erreurs de base de données** : Via `/error`
   - **Timeouts** : 30% de chance sur `/slow`
   - **Erreurs de validation, permission, timeout** : Via `/error`

3. **Requêtes PromQL**
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

#### 5.2 Configuration Grafana
1. **Dashboard Personnalisé**
   - Créer un nouveau dashboard
   - Ajouter des panels pour :
     - Taux de requêtes (Graph)
     - Taux d'erreur (Gauge)
     - Erreurs par type (Bar chart)
     - Uptime (Stat)

2. **Alerting**
   - Configurer des alertes basées sur les métriques
   - Tester les notifications

### Étape 6 : Tests de Charge et Monitoring (1h)

#### 6.1 Scripts de Test Disponibles
Le projet inclut plusieurs scripts pour générer du trafic et tester l'observabilité :

**Scripts principaux :**
- `quick_test.sh` : Test rapide avec génération d'erreurs
- `generate_traffic.sh` : Trafic contrôlé avec nombre de requêtes et durée
- `background_traffic.sh` : Trafic en arrière-plan continu
- `traffic_spike.sh` : Stress test avec plusieurs threads
- `continuous_traffic.sh` : Trafic continu avec différentes intensités

#### 6.2 Utilisation des Scripts
```bash
# Test rapide (recommandé pour débuter)
./scripts/quick_test.sh

# Génération de trafic contrôlé
./scripts/generate_traffic.sh 100 60

# Trafic en arrière-plan
./scripts/background_traffic.sh start
./scripts/background_traffic.sh status
./scripts/background_traffic.sh stop

# Stress test
./scripts/traffic_spike.sh 5 30

# Trafic continu
./scripts/continuous_traffic.sh high
```

#### 6.3 Observation des Métriques
- Surveiller les graphiques en temps réel dans Grafana
- Vérifier la collecte des métriques dans Prometheus
- Analyser les performances et les erreurs
- Utiliser les requêtes PromQL pour explorer les données

### Étape 7 : Nettoyage (30 min)

#### 7.1 Arrêt des Services
```bash
# Arrêter les services sur chaque serveur
sudo systemctl stop flask-app
sudo systemctl stop prometheus
sudo systemctl stop grafana-server

# Optionnel : Désinstaller les composants
# (selon les besoins de l'environnement)
```

## 📊 Captures d'Écran Attendues

### 1. Interface Prometheus
- **Targets** : Page Status → Targets avec flask-app en statut "UP"
- **Graph** : Requêtes PromQL avec métriques Flask
- **Alerts** : Configuration d'alertes (optionnel)

### 2. Interface Grafana
- **Login** : Page de connexion Grafana
- **Datasources** : Datasource Prometheus configurée et testée
- **Dashboard** : Dashboard Flask avec panels fonctionnels
- **Explore** : Requêtes PromQL sur les métriques

### 3. Application Flask
- **Home** : Page d'accueil avec message de statut
- **Health** : Endpoint de santé avec réponse JSON
- **Stats** : Métriques en temps réel (uptime, erreurs, taux)
- **Metrics** : Endpoint Prometheus avec métriques exposées

## 🎯 Barème de Validation

| Critère | Points | Description |
|---------|--------|-------------|
| **Installation** | 25 | Services installés et configurés |
| **Prometheus** | 25 | Collecte de métriques fonctionnelle |
| **Grafana** | 25 | Datasource OK, dashboard opérationnel |
| **Tests** | 15 | Application Flask et scripts de test |
| **Documentation** | 10 | Captures d'écran, rapport |

**Total : 100 points**

### Critères de Réussite
- ✅ Services installés et configurés sans erreur
- ✅ Tous les services accessibles
- ✅ Prometheus collecte les métriques
- ✅ Grafana dashboard avec données
- ✅ Scripts de test fonctionnels

## 🔧 Dépannage

### Problèmes Courants

#### 1. Problème de Connectivité Réseau
```
Connection refused ou timeout
```
**Solution** : Vérifier les règles de firewall et la connectivité réseau entre les serveurs

#### 2. Service Non Accessible
```
Service not found ou port fermé
```
**Solution** : Vérifier que les services sont démarrés et que les ports sont ouverts

#### 3. Prometheus Ne Collecte Pas les Métriques
```
Target flask-app is DOWN
```
**Solution** : Vérifier que Flask expose `/metrics` et que Prometheus peut accéder au port 5000

#### 4. Datasource Grafana Non Fonctionnelle
```
Failed to connect to Prometheus
```
**Solution** : Vérifier l'URL Prometheus et la connectivité réseau

## 📚 Ressources Supplémentaires

### Documentation
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Python Client](https://github.com/prometheus/client_python)
- [Flask Documentation](https://flask.palletsprojects.com/)

### Commandes Utiles
```bash
# Tester la connectivité
telnet IP 5000
telnet IP 9090
telnet IP 3000

# Vérifier les services
systemctl status flask-app
systemctl status prometheus
systemctl status grafana-server

# Consulter les logs
journalctl -u flask-app -f
journalctl -u prometheus -f
journalctl -u grafana-server -f

# Tester les métriques
curl http://APP_IP:5000/metrics
curl http://PROMETHEUS_IP:9090/api/v1/query?query=up
```

## 🎉 Conclusion

Ce TP vous a permis de :
- Déployer une stack de monitoring moderne (Prometheus + Grafana)
- Instrumenter une application avec des métriques Prometheus
- Créer des dashboards de visualisation
- Automatiser les tests de charge
- Comprendre les concepts d'observabilité moderne

Ces compétences sont essentielles pour tout ingénieur DevOps/Cloud souhaitant mettre en place des infrastructures observables avec des outils de monitoring de nouvelle génération.
