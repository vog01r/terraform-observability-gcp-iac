#!/bin/bash

# Script de démonstration pour l'observabilité
# Ce script lance différents types de tests pour faire bouger les graphiques

APP_URL="http://34.69.67.242:5000"
PROMETHEUS_URL="http://35.224.152.222:9090"
GRAFANA_URL="http://34.59.124.63:3000"

echo "🎯 DÉMONSTRATION OBSERVABILITÉ"
echo "=============================="
echo ""
echo "🌐 URLs d'accès:"
echo "• Application Flask: $APP_URL"
echo "• Prometheus: $PROMETHEUS_URL"
echo "• Grafana: $GRAFANA_URL"
echo ""

# Fonction pour afficher les statistiques
show_stats() {
    echo "📊 Statistiques actuelles:"
    echo "========================="
    curl -s "$APP_URL/stats" | python3 -m json.tool 2>/dev/null || echo "Impossible de récupérer les stats"
    echo ""
}

# Fonction pour afficher les métriques Prometheus
show_prometheus_metrics() {
    echo "🔍 Métriques Prometheus:"
    echo "======================="
    
    echo "• Requêtes totales:"
    curl -s "$PROMETHEUS_URL/api/v1/query?query=flask_requests_total" | python3 -c "
import json, sys
data = json.load(sys.stdin)
if 'data' in data and 'result' in data['data']:
    for result in data['data']['result']:
        metric = result['metric']
        value = result['value'][1]
        print(f'  - {metric[\"endpoint\"]} ({metric[\"status\"]}): {value}')
" 2>/dev/null || echo "  Impossible de récupérer les métriques"
    
    echo ""
    echo "• Erreurs par type:"
    curl -s "$PROMETHEUS_URL/api/v1/query?query=flask_errors_total" | python3 -c "
import json, sys
data = json.load(sys.stdin)
if 'data' in data and 'result' in data['data']:
    for result in data['data']['result']:
        metric = result['metric']
        value = result['value'][1]
        print(f'  - {metric[\"error_type\"]}: {value}')
" 2>/dev/null || echo "  Impossible de récupérer les métriques d'erreur"
    
    echo ""
    echo "• Taux d'erreur:"
    curl -s "$PROMETHEUS_URL/api/v1/query?query=flask_error_rate" | python3 -c "
import json, sys
data = json.load(sys.stdin)
if 'data' in data and 'result' in data['data']:
    for result in data['data']['result']:
        value = result['value'][1]
        print(f'  - Taux d'erreur actuel: {value}%')
" 2>/dev/null || echo "  Impossible de récupérer le taux d'erreur"
    
    echo ""
}

# Fonction pour générer du trafic de base
generate_baseline_traffic() {
    echo "🚀 Phase 1: Génération de trafic de base (30 requêtes)"
    echo "====================================================="
    
    for i in {1..30}; do
        case $((RANDOM % 4)) in
            0) curl -s "$APP_URL/" > /dev/null ;;
            1) curl -s "$APP_URL/health" > /dev/null ;;
            2) curl -s "$APP_URL/stats" > /dev/null ;;
            3) curl -s "$APP_URL/error" > /dev/null ;;
        esac
        
        if [ $((i % 10)) -eq 0 ]; then
            echo "  📊 $i requêtes effectuées..."
        fi
        
        sleep 0.5
    done
    
    echo "✅ Trafic de base terminé"
    echo ""
    show_stats
    echo ""
}

# Fonction pour générer des pics d'erreurs
generate_error_spike() {
    echo "❌ Phase 2: Génération de pics d'erreurs (20 requêtes vers /error)"
    echo "================================================================="
    
    for i in {1..20}; do
        curl -s "$APP_URL/error" > /dev/null
        echo "  ❌ Erreur $i générée"
        sleep 0.3
    done
    
    echo "✅ Pics d'erreurs terminés"
    echo ""
    show_stats
    echo ""
}

# Fonction pour générer des timeouts
generate_timeout_spike() {
    echo "🐌 Phase 3: Génération de timeouts (15 requêtes vers /slow)"
    echo "=========================================================="
    
    for i in {1..15}; do
        curl -s "$APP_URL/slow" > /dev/null
        echo "  🐌 Requête lente $i"
        sleep 0.4
    done
    
    echo "✅ Timeouts terminés"
    echo ""
    show_stats
    echo ""
}

# Fonction pour générer du trafic intense
generate_intense_traffic() {
    echo "⚡ Phase 4: Trafic intense (50 requêtes rapides)"
    echo "==============================================="
    
    for i in {1..50}; do
        case $((RANDOM % 5)) in
            0) curl -s "$APP_URL/" > /dev/null ;;
            1) curl -s "$APP_URL/health" > /dev/null ;;
            2) curl -s "$APP_URL/stats" > /dev/null ;;
            3) curl -s "$APP_URL/error" > /dev/null ;;
            4) curl -s "$APP_URL/slow" > /dev/null ;;
        esac
        
        if [ $((i % 10)) -eq 0 ]; then
            echo "  ⚡ $i requêtes rapides effectuées..."
        fi
        
        sleep 0.1
    done
    
    echo "✅ Trafic intense terminé"
    echo ""
    show_stats
    echo ""
}

# Fonction pour afficher les instructions Grafana
show_grafana_instructions() {
    echo "📊 INSTRUCTIONS POUR GRAFANA"
    echo "============================"
    echo ""
    echo "1. Ouvrez Grafana: $GRAFANA_URL"
    echo "2. Connectez-vous avec admin/admin"
    echo "3. Allez dans 'Explore' ou créez un nouveau dashboard"
    echo "4. Utilisez ces requêtes Prometheus:"
    echo ""
    echo "   • Requêtes totales:"
    echo "     sum(rate(flask_requests_total[5m]))"
    echo ""
    echo "   • Taux d'erreur:"
    echo "     flask_error_rate"
    echo ""
    echo "   • Erreurs par type:"
    echo "     sum by (error_type) (flask_errors_total)"
    echo ""
    echo "   • Temps de réponse:"
    echo "     histogram_quantile(0.95, rate(flask_request_duration_seconds_bucket[5m]))"
    echo ""
    echo "5. Lancez ce script plusieurs fois pour voir les graphiques évoluer !"
    echo ""
}

# Menu principal
show_menu() {
    echo "🎯 MENU DE DÉMONSTRATION"
    echo "========================"
    echo ""
    echo "1. Afficher les statistiques actuelles"
    echo "2. Générer du trafic de base"
    echo "3. Générer des pics d'erreurs"
    echo "4. Générer des timeouts"
    echo "5. Générer du trafic intense"
    echo "6. Démonstration complète (toutes les phases)"
    echo "7. Afficher les instructions Grafana"
    echo "8. Quitter"
    echo ""
    read -p "Choisissez une option (1-8): " choice
    
    case $choice in
        1)
            show_stats
            show_prometheus_metrics
            ;;
        2)
            generate_baseline_traffic
            ;;
        3)
            generate_error_spike
            ;;
        4)
            generate_timeout_spike
            ;;
        5)
            generate_intense_traffic
            ;;
        6)
            echo "🎬 DÉMONSTRATION COMPLÈTE"
            echo "========================="
            echo ""
            generate_baseline_traffic
            sleep 2
            generate_error_spike
            sleep 2
            generate_timeout_spike
            sleep 2
            generate_intense_traffic
            echo "🎉 Démonstration complète terminée !"
            echo ""
            show_prometheus_metrics
            ;;
        7)
            show_grafana_instructions
            ;;
        8)
            echo "👋 Au revoir !"
            exit 0
            ;;
        *)
            echo "❌ Option invalide"
            ;;
    esac
}

# Vérifier la connectivité
echo "🔍 Test de connectivité..."
if ! curl -s --connect-timeout 5 "$APP_URL/health" > /dev/null; then
    echo "❌ Application non accessible. Vérifiez que l'application est démarrée."
    exit 1
fi
echo "✅ Application accessible"
echo ""

# Boucle principale
while true; do
    show_menu
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
    echo ""
done
