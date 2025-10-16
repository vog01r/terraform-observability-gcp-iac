#!/bin/bash

# Script pour générer du trafic continu sur l'application Flask
# Usage: ./continuous_traffic.sh [intensite]

APP_URL="http://34.69.67.242:5000"
INTENSITY=${1:-"normal"}

echo "🔄 Génération de trafic continu"
echo "=============================="
echo "URL: $APP_URL"
echo "Intensité: $INTENSITY"
echo ""
echo "Appuyez sur Ctrl+C pour arrêter"
echo ""

# Définir les intervalles selon l'intensité
case $INTENSITY in
    "low")
        MIN_SLEEP=2
        MAX_SLEEP=5
        echo "🐌 Mode lent: 2-5 secondes entre les requêtes"
        ;;
    "high")
        MIN_SLEEP=0.1
        MAX_SLEEP=0.5
        echo "🚀 Mode rapide: 0.1-0.5 secondes entre les requêtes"
        ;;
    "normal"|*)
        MIN_SLEEP=0.5
        MAX_SLEEP=2
        echo "⚡ Mode normal: 0.5-2 secondes entre les requêtes"
        ;;
esac

# Compteurs
REQUEST_COUNT=0
ERROR_COUNT=0

# Fonction pour nettoyer à la sortie
cleanup() {
    echo ""
    echo "🛑 Arrêt du script..."
    echo "📊 Statistiques finales:"
    echo "   • Total des requêtes: $REQUEST_COUNT"
    echo "   • Erreurs détectées: $ERROR_COUNT"
    echo "   • Taux d'erreur: $(echo "scale=2; $ERROR_COUNT * 100 / $REQUEST_COUNT" | bc -l)%"
    exit 0
}

# Capturer Ctrl+C
trap cleanup SIGINT

echo "⏰ Début de la génération de trafic continu..."
echo ""

while true; do
    # Choisir un endpoint aléatoire
    case $((RANDOM % 6)) in
        0)
            echo "📊 [$(date '+%H:%M:%S')] Requête vers / (page d'accueil)"
            RESPONSE=$(curl -s -w "%{http_code}" "$APP_URL/")
            ;;
        1)
            echo "🏥 [$(date '+%H:%M:%S')] Requête vers /health (health check)"
            RESPONSE=$(curl -s -w "%{http_code}" "$APP_URL/health")
            ;;
        2)
            echo "📈 [$(date '+%H:%M:%S')] Requête vers /stats (statistiques)"
            RESPONSE=$(curl -s -w "%{http_code}" "$APP_URL/stats")
            ;;
        3)
            echo "❌ [$(date '+%H:%M:%S')] Requête vers /error (génération d'erreur)"
            RESPONSE=$(curl -s -w "%{http_code}" "$APP_URL/error")
            ;;
        4)
            echo "🐌 [$(date '+%H:%M:%S')] Requête vers /slow (endpoint lent)"
            RESPONSE=$(curl -s -w "%{http_code}" "$APP_URL/slow")
            ;;
        5)
            echo "📊 [$(date '+%H:%M:%S')] Requête vers /metrics (métriques Prometheus)"
            RESPONSE=$(curl -s -w "%{http_code}" "$APP_URL/metrics")
            ;;
    esac
    
    REQUEST_COUNT=$((REQUEST_COUNT + 1))
    
    # Extraire le code de statut HTTP
    HTTP_CODE=$(echo "$RESPONSE" | tail -c 4)
    
    # Compter les erreurs (codes 4xx et 5xx)
    if [[ "$HTTP_CODE" =~ ^[45][0-9][0-9]$ ]]; then
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo "   ❌ Erreur HTTP: $HTTP_CODE"
    else
        echo "   ✅ Succès HTTP: $HTTP_CODE"
    fi
    
    # Afficher les statistiques toutes les 20 requêtes
    if [ $((REQUEST_COUNT % 20)) -eq 0 ]; then
        echo ""
        echo "📊 Statistiques actuelles:"
        echo "   • Requêtes: $REQUEST_COUNT"
        echo "   • Erreurs: $ERROR_COUNT"
        echo "   • Taux d'erreur: $(echo "scale=2; $ERROR_COUNT * 100 / $REQUEST_COUNT" | bc -l)%"
        echo ""
    fi
    
    # Attendre avant la prochaine requête
    SLEEP_TIME=$(echo "scale=2; $MIN_SLEEP + ($RANDOM/32768) * ($MAX_SLEEP - $MIN_SLEEP)" | bc -l)
    sleep $SLEEP_TIME
done
