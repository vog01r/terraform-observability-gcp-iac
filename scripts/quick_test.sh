#!/bin/bash

# Script rapide pour tester l'observabilité
# Usage: ./quick_test.sh [type]

APP_URL="http://34.69.67.242:5000"

echo "⚡ TEST RAPIDE OBSERVABILITÉ"
echo "==========================="
echo ""

# Fonction pour afficher les URLs
show_urls() {
    echo "🌐 URLs d'accès:"
    echo "• Application Flask: $APP_URL"
    echo "• Prometheus: http://35.224.152.222:9090"
    echo "• Grafana: http://34.59.124.63:3000"
    echo ""
}

# Fonction pour générer du trafic rapide
quick_traffic() {
    echo "🚀 Génération de trafic rapide (20 requêtes)..."
    for i in {1..20}; do
        case $((RANDOM % 4)) in
            0) curl -s "$APP_URL/" > /dev/null ;;
            1) curl -s "$APP_URL/health" > /dev/null ;;
            2) curl -s "$APP_URL/error" > /dev/null ;;
            3) curl -s "$APP_URL/slow" > /dev/null ;;
        esac
        echo -n "."
        sleep 0.2
    done
    echo ""
    echo "✅ Trafic généré !"
}

# Fonction pour générer des erreurs
generate_errors() {
    echo "❌ Génération d'erreurs (15 requêtes vers /error)..."
    for i in {1..15}; do
        curl -s "$APP_URL/error" > /dev/null
        echo -n "."
        sleep 0.3
    done
    echo ""
    echo "✅ Erreurs générées !"
}

# Fonction pour afficher les stats
show_stats() {
    echo "📊 Statistiques actuelles:"
    curl -s "$APP_URL/stats" | python3 -m json.tool 2>/dev/null || echo "Impossible de récupérer les stats"
}

# Fonction pour tester la connectivité
test_connectivity() {
    echo "🔍 Test de connectivité..."
    if curl -s --connect-timeout 5 "$APP_URL/health" > /dev/null; then
        echo "✅ Application accessible"
        return 0
    else
        echo "❌ Application non accessible"
        return 1
    fi
}

# Gestion des arguments
case "${1:-all}" in
    "traffic")
        test_connectivity && quick_traffic && show_stats
        ;;
    "errors")
        test_connectivity && generate_errors && show_stats
        ;;
    "stats")
        test_connectivity && show_stats
        ;;
    "urls")
        show_urls
        ;;
    "all"|*)
        test_connectivity && quick_traffic && generate_errors && show_stats && show_urls
        ;;
esac

echo ""
echo "🎯 Consultez Grafana pour voir les graphiques évoluer !"
