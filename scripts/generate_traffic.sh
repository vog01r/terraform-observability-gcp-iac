#!/bin/bash

# Script pour générer du trafic et des erreurs sur l'application Flask
# Usage: ./generate_traffic.sh [nombre_de_requetes] [duree_en_secondes]

APP_URL="http://34.69.67.242:5000"
DEFAULT_REQUESTS=100
DEFAULT_DURATION=60

# Paramètres
REQUESTS=${1:-$DEFAULT_REQUESTS}
DURATION=${2:-$DEFAULT_DURATION}

echo "🚀 Génération de trafic pour l'application Flask"
echo "=============================================="
echo "URL: $APP_URL"
echo "Nombre de requêtes: $REQUESTS"
echo "Durée: $DURATION secondes"
echo ""

# Fonction pour générer du trafic
generate_traffic() {
    local count=0
    local start_time=$(date +%s)
    local end_time=$((start_time + DURATION))
    
    echo "⏰ Début de la génération de trafic..."
    
    while [ $(date +%s) -lt $end_time ] && [ $count -lt $REQUESTS ]; do
        # Générer des requêtes aléatoires
        case $((RANDOM % 5)) in
            0)
                echo "📊 Requête vers / (page d'accueil)"
                curl -s "$APP_URL/" > /dev/null
                ;;
            1)
                echo "🏥 Requête vers /health (health check)"
                curl -s "$APP_URL/health" > /dev/null
                ;;
            2)
                echo "📈 Requête vers /stats (statistiques)"
                curl -s "$APP_URL/stats" > /dev/null
                ;;
            3)
                echo "❌ Requête vers /error (génération d'erreur)"
                curl -s "$APP_URL/error" > /dev/null
                ;;
            4)
                echo "🐌 Requête vers /slow (endpoint lent)"
                curl -s "$APP_URL/slow" > /dev/null
                ;;
        esac
        
        count=$((count + 1))
        
        # Afficher le progrès
        if [ $((count % 10)) -eq 0 ]; then
            echo "📊 Progrès: $count requêtes effectuées"
        fi
        
        # Attendre entre 0.5 et 2 secondes
        sleep $(echo "scale=1; $RANDOM/32768*1.5+0.5" | bc -l)
    done
    
    echo ""
    echo "✅ Génération de trafic terminée !"
    echo "📊 Total des requêtes: $count"
}

# Fonction pour afficher les statistiques
show_stats() {
    echo ""
    echo "📈 Statistiques actuelles de l'application:"
    echo "=========================================="
    
    # Récupérer les stats
    STATS=$(curl -s "$APP_URL/stats")
    if [ $? -eq 0 ]; then
        echo "$STATS" | python3 -m json.tool 2>/dev/null || echo "$STATS"
    else
        echo "❌ Impossible de récupérer les statistiques"
    fi
    
    echo ""
    echo "🔍 Métriques Prometheus disponibles:"
    echo "===================================="
    echo "• flask_requests_total - Nombre total de requêtes"
    echo "• flask_errors_total - Nombre d'erreurs par type"
    echo "• flask_error_rate - Taux d'erreur en pourcentage"
    echo "• flask_uptime_seconds - Temps de fonctionnement"
    echo "• flask_request_duration_seconds - Durée des requêtes"
    
    echo ""
    echo "🌐 URLs d'accès:"
    echo "==============="
    echo "• Application Flask: $APP_URL"
    echo "• Prometheus: http://35.224.152.222:9090"
    echo "• Grafana: http://34.59.124.63:3000"
}

# Fonction pour tester la connectivité
test_connectivity() {
    echo "🔍 Test de connectivité..."
    
    if curl -s --connect-timeout 5 "$APP_URL/health" > /dev/null; then
        echo "✅ Application Flask accessible"
        return 0
    else
        echo "❌ Application Flask non accessible"
        return 1
    fi
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [nombre_de_requetes] [duree_en_secondes]"
    echo ""
    echo "Exemples:"
    echo "  $0                    # 100 requêtes sur 60 secondes"
    echo "  $0 50                 # 50 requêtes sur 60 secondes"
    echo "  $0 200 120            # 200 requêtes sur 120 secondes"
    echo ""
    echo "Options:"
    echo "  -h, --help           Afficher cette aide"
    echo "  -s, --stats          Afficher les statistiques actuelles"
    echo "  -t, --test           Tester la connectivité"
}

# Gestion des arguments
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -s|--stats)
        show_stats
        exit 0
        ;;
    -t|--test)
        test_connectivity
        exit $?
        ;;
esac

# Vérifier la connectivité avant de commencer
if ! test_connectivity; then
    echo "❌ Impossible de se connecter à l'application. Vérifiez que l'application est démarrée."
    exit 1
fi

# Générer le trafic
generate_traffic

# Afficher les statistiques finales
show_stats

echo ""
echo "🎉 Script terminé ! Consultez Grafana pour voir les graphiques évoluer."
