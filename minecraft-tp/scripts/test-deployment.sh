#!/bin/bash
# Script de test pour vérifier le bon fonctionnement du déploiement
# Teste tous les services et composants

set -euo pipefail

echo "=== Test du déploiement TP Minecraft - Observabilité ==="

# Récupération des IPs depuis Terraform
cd "$(dirname "$0")/../terraform"
MINECRAFT_IP=$(terraform output -raw minecraft_server_ip 2>/dev/null || echo "")
MONITORING_IP=$(terraform output -raw monitoring_server_ip 2>/dev/null || echo "")

if [ -z "$MINECRAFT_IP" ] || [ -z "$MONITORING_IP" ]; then
    echo "❌ Impossible de récupérer les IPs. Assurez-vous que Terraform a été déployé."
    exit 1
fi

echo "🖥️  Serveur Minecraft: $MINECRAFT_IP"
echo "📈 Serveur Monitoring: $MONITORING_IP"
echo ""

# Fonction de test de connectivité
test_connectivity() {
    local host=$1
    local port=$2
    local service=$3
    
    if timeout 10 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        echo "✅ $service accessible sur $host:$port"
        return 0
    else
        echo "❌ $service non accessible sur $host:$port"
        return 1
    fi
}

# Fonction de test HTTP
test_http() {
    local url=$1
    local service=$2
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo "✅ $service répond correctement sur $url"
        return 0
    else
        echo "❌ $service ne répond pas sur $url"
        return 1
    fi
}

# Tests de connectivité
echo "🧪 Tests de connectivité..."

# Test SSH
echo "Test SSH..."
if ssh -i ~/.ssh/id_rsa -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@$MINECRAFT_IP "echo 'SSH OK'" > /dev/null 2>&1; then
    echo "✅ SSH accessible sur le serveur Minecraft"
else
    echo "❌ SSH non accessible sur le serveur Minecraft"
fi

if ssh -i ~/.ssh/id_rsa -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@$MONITORING_IP "echo 'SSH OK'" > /dev/null 2>&1; then
    echo "✅ SSH accessible sur le serveur Monitoring"
else
    echo "❌ SSH non accessible sur le serveur Monitoring"
fi

# Test des ports
echo ""
echo "Test des ports..."

test_connectivity $MINECRAFT_IP 22 "SSH Minecraft"
test_connectivity $MINECRAFT_IP 25565 "Minecraft Server"
test_connectivity $MINECRAFT_IP 9100 "Node Exporter"
test_connectivity $MONITORING_IP 22 "SSH Monitoring"
test_connectivity $MONITORING_IP 9090 "Prometheus"
test_connectivity $MONITORING_IP 3000 "Grafana"

# Tests HTTP
echo ""
echo "🧪 Tests HTTP..."

test_http "http://$MONITORING_IP:9090/api/v1/status/config" "Prometheus API"
test_http "http://$MONITORING_IP:3000/api/health" "Grafana API"
test_http "http://$MINECRAFT_IP:9100/metrics" "Node Exporter Metrics"

# Test des services sur le serveur Minecraft
echo ""
echo "🧪 Test des services sur le serveur Minecraft..."

echo "Test du service LinuxGSM..."
if ssh -i ~/.ssh/id_rsa -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@$MINECRAFT_IP "sudo -u mcserver /home/mcserver/mcserver details" > /dev/null 2>&1; then
    echo "✅ Service LinuxGSM fonctionne"
else
    echo "❌ Service LinuxGSM ne fonctionne pas"
fi

echo "Test du service Node Exporter..."
if ssh -i ~/.ssh/id_rsa -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@$MINECRAFT_IP "systemctl is-active node_exporter" | grep -q "active"; then
    echo "✅ Service Node Exporter actif"
else
    echo "❌ Service Node Exporter inactif"
fi

# Test des services sur le serveur Monitoring
echo ""
echo "🧪 Test des services sur le serveur Monitoring..."

echo "Test des conteneurs Docker..."
if ssh -i ~/.ssh/id_rsa -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@$MONITORING_IP "docker ps --format 'table {{.Names}}\t{{.Status}}'" 2>/dev/null; then
    echo "✅ Conteneurs Docker en cours d'exécution"
else
    echo "❌ Problème avec les conteneurs Docker"
fi

# Test de la configuration Prometheus
echo ""
echo "🧪 Test de la configuration Prometheus..."

echo "Test des targets Prometheus..."
if curl -s "http://$MONITORING_IP:9090/api/v1/targets" | grep -q "minecraft-server"; then
    echo "✅ Target minecraft-server configuré dans Prometheus"
else
    echo "❌ Target minecraft-server non trouvé dans Prometheus"
fi

# Test des métriques
echo ""
echo "🧪 Test des métriques..."

echo "Test des métriques système..."
if curl -s "http://$MINECRAFT_IP:9100/metrics" | grep -q "node_cpu_seconds_total"; then
    echo "✅ Métriques système disponibles"
else
    echo "❌ Métriques système non disponibles"
fi

# Test de Grafana
echo ""
echo "🧪 Test de Grafana..."

echo "Test de l'authentification Grafana..."
if curl -s -u admin:admin123 "http://$MONITORING_IP:3000/api/org" | grep -q "id"; then
    echo "✅ Authentification Grafana fonctionne"
else
    echo "❌ Authentification Grafana ne fonctionne pas"
fi

# Résumé des tests
echo ""
echo "=== Résumé des tests ==="
echo "🎮 Serveur Minecraft: $MINECRAFT_IP"
echo "📊 Serveur Monitoring: $MONITORING_IP"
echo ""
echo "🔗 URLs d'accès:"
echo "🎮 Minecraft: minecraft://$MINECRAFT_IP:25565"
echo "📊 Prometheus: http://$MONITORING_IP:9090"
echo "📈 Grafana: http://$MONITORING_IP:3000 (admin/admin123)"
echo ""
echo "📝 Commandes utiles:"
echo "ssh -i ~/.ssh/id_rsa ubuntu@$MINECRAFT_IP"
echo "ssh -i ~/.ssh/id_rsa ubuntu@$MONITORING_IP"
echo ""
echo "🎉 Tests terminés!"
