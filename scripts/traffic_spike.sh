#!/bin/bash

# Script pour générer des pics de trafic (stress test)
# Usage: ./traffic_spike.sh [nombre_de_threads] [duree_en_secondes]

APP_URL="http://34.69.67.242:5000"
THREADS=${1:-5}
DURATION=${2:-30}

echo "⚡ Génération de pics de trafic (Stress Test)"
echo "==========================================="
echo "URL: $APP_URL"
echo "Threads: $THREADS"
echo "Durée: $DURATION secondes"
echo ""

# Fonction pour générer du trafic dans un thread
generate_traffic_thread() {
    local thread_id=$1
    local end_time=$(($(date +%s) + DURATION))
    local count=0
    
    echo "🚀 Thread $thread_id démarré"
    
    while [ $(date +%s) -lt $end_time ]; do
        # Générer des requêtes rapides
        case $((RANDOM % 4)) in
            0)
                curl -s "$APP_URL/health" > /dev/null
                ;;
            1)
                curl -s "$APP_URL/error" > /dev/null
                ;;
            2)
                curl -s "$APP_URL/slow" > /dev/null
                ;;
            3)
                curl -s "$APP_URL/" > /dev/null
                ;;
        esac
        
        count=$((count + 1))
        
        # Attendre très peu entre les requêtes (stress test)
        sleep 0.1
    done
    
    echo "✅ Thread $thread_id terminé: $count requêtes"
}

# Fonction pour afficher les statistiques en temps réel
monitor_stats() {
    local end_time=$(($(date +%s) + DURATION))
    
    while [ $(date +%s) -lt $end_time ]; do
        sleep 5
        echo ""
        echo "📊 Statistiques en temps réel:"
        curl -s "$APP_URL/stats" | python3 -m json.tool 2>/dev/null || echo "Impossible de récupérer les stats"
        echo ""
    done
}

# Vérifier la connectivité
echo "🔍 Test de connectivité..."
if ! curl -s --connect-timeout 5 "$APP_URL/health" > /dev/null; then
    echo "❌ Application non accessible"
    exit 1
fi
echo "✅ Application accessible"
echo ""

# Démarrer le monitoring en arrière-plan
monitor_stats &
MONITOR_PID=$!

# Démarrer les threads de génération de trafic
echo "🚀 Démarrage de $THREADS threads..."
PIDS=()

for i in $(seq 1 $THREADS); do
    generate_traffic_thread $i &
    PIDS+=($!)
done

# Attendre que tous les threads se terminent
echo "⏳ Attente de la fin des threads..."
for pid in "${PIDS[@]}"; do
    wait $pid
done

# Arrêter le monitoring
kill $MONITOR_PID 2>/dev/null

echo ""
echo "🎉 Stress test terminé !"
echo ""
echo "📊 Statistiques finales:"
curl -s "$APP_URL/stats" | python3 -m json.tool 2>/dev/null || echo "Impossible de récupérer les stats finales"

echo ""
echo "🌐 Consultez Grafana pour voir l'impact sur les graphiques:"
echo "   http://34.59.124.63:3000"
