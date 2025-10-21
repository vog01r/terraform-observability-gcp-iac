# 📘 Guide d'installation

Ce document complète le `README.md` principal et détaille la mise en place de la stack Observabilité GCP.

## 1. Prérequis

- Compte Google Cloud avec facturation activée
- Terraform ≥ 1.5, Ansible ≥ 2.14, gcloud CLI, jq
- Clé SSH publique (par défaut `~/.ssh/id_rsa.pub`)
- Fichier JSON d’un service account GCP (rôle Compute Admin)

## 2. Clonage du dépôt

```bash
git clone git@github.com:vog01r/terraform-observability-gcp-iac.git
cd terraform-observability-gcp-iac
```

## 3. Configuration Terraform

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
vim terraform/terraform.tfvars
# -> project_id, region, zone, ssh_user, ssh_public_key_path
export GOOGLE_APPLICATION_CREDENTIALS="/chemin/cle-gcp.json"
```

## 4. Déploiement complet

```bash
make all
```

Cette commande enchaîne :

1. `terraform init/plan/apply`
2. Attente de la connectivité SSH (`scripts/check-ssh.sh`)
3. `ansible-playbook ansible/site.yml`

## 5. Résultats

```
App      : http://APP_IP:5000
Zabbix   : http://ZABBIX_IP/zabbix (Admin / zabbix)
Grafana  : http://GRAFANA_IP:3000 (admin / admin)
```

Consulter `terraform -chdir=terraform output` pour afficher les IP/URLs.

## 6. Validation rapide

```bash
curl http://APP_IP:5000/health
ansible all -i ansible/inventory/inventory.ini -m ping
```

## 7. Nettoyage

```bash
make destroy
```

## 8. Dépannage

- Erreur quota GCP : réduire le type de VM dans `terraform.tfvars`
- SSH KO : vérifier firewall GCP et clés SSH
- Playbook échoue : relancer `make provision` après résolution (logs dans `/var/log/ansible.log` si configuré)

## 9. Assets visuels

- `docs/assets/architecture.png`
- `docs/assets/grafana-dashboard.png`

Ces visuels sont prêts pour un post LinkedIn.

## 10. Ressources complémentaires

- README principal : opérations en 5 minutes
- `docs/TP.md` : scénario pédagogique
- `docs/Cours_Observabilite.md` : support de formation complet
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
