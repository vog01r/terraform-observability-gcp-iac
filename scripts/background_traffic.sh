#!/bin/bash

# Script pour générer du trafic en arrière-plan
# Usage: ./background_traffic.sh [start|stop|status]

APP_URL="http://34.69.67.242:5000"
PID_FILE="/tmp/background_traffic.pid"
LOG_FILE="/tmp/background_traffic.log"

# Fonction pour démarrer le trafic en arrière-plan
start_traffic() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "⚠️  Le trafic en arrière-plan est déjà en cours d'exécution (PID: $(cat $PID_FILE))"
        return 1
    fi
    
    echo "🚀 Démarrage du trafic en arrière-plan..."
    
    # Fonction de génération de trafic
    generate_background_traffic() {
        local count=0
        while true; do
            # Générer des requêtes aléatoires
            case $((RANDOM % 5)) in
                0) curl -s "$APP_URL/" > /dev/null ;;
                1) curl -s "$APP_URL/health" > /dev/null ;;
                2) curl -s "$APP_URL/stats" > /dev/null ;;
                3) curl -s "$APP_URL/error" > /dev/null ;;
                4) curl -s "$APP_URL/slow" > /dev/null ;;
            esac
            
            count=$((count + 1))
            
            # Logger toutes les 100 requêtes
            if [ $((count % 100)) -eq 0 ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] $count requêtes effectuées" >> "$LOG_FILE"
            fi
            
            # Attendre entre 1 et 3 secondes
            sleep $((RANDOM % 3 + 1))
        done
    }
    
    # Démarrer en arrière-plan
    generate_background_traffic &
    echo $! > "$PID_FILE"
    
    echo "✅ Trafic en arrière-plan démarré (PID: $(cat $PID_FILE))"
    echo "📝 Logs: $LOG_FILE"
    echo "🛑 Pour arrêter: $0 stop"
}

# Fonction pour arrêter le trafic
stop_traffic() {
    if [ ! -f "$PID_FILE" ]; then
        echo "⚠️  Aucun trafic en arrière-plan en cours d'exécution"
        return 1
    fi
    
    local pid=$(cat "$PID_FILE")
    
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        rm -f "$PID_FILE"
        echo "🛑 Trafic en arrière-plan arrêté (PID: $pid)"
    else
        echo "⚠️  Le processus n'existe plus, nettoyage du fichier PID"
        rm -f "$PID_FILE"
    fi
}

# Fonction pour afficher le statut
show_status() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        local pid=$(cat "$PID_FILE")
        echo "✅ Trafic en arrière-plan actif (PID: $pid)"
        
        if [ -f "$LOG_FILE" ]; then
            echo "📝 Dernières entrées du log:"
            tail -5 "$LOG_FILE"
        fi
        
        echo ""
        echo "📊 Statistiques actuelles de l'application:"
        curl -s "$APP_URL/stats" | python3 -m json.tool 2>/dev/null || echo "Impossible de récupérer les stats"
    else
        echo "❌ Aucun trafic en arrière-plan en cours d'exécution"
        if [ -f "$PID_FILE" ]; then
            rm -f "$PID_FILE"
        fi
    fi
}

# Fonction pour afficher les logs
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "📝 Logs du trafic en arrière-plan:"
        echo "=================================="
        tail -20 "$LOG_FILE"
    else
        echo "⚠️  Aucun fichier de log trouvé"
    fi
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [start|stop|status|logs|help]"
    echo ""
    echo "Commandes:"
    echo "  start   - Démarrer le trafic en arrière-plan"
    echo "  stop    - Arrêter le trafic en arrière-plan"
    echo "  status  - Afficher le statut et les statistiques"
    echo "  logs    - Afficher les logs"
    echo "  help    - Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 start    # Démarrer le trafic"
    echo "  $0 status   # Voir le statut"
    echo "  $0 stop     # Arrêter le trafic"
}

# Gestion des arguments
case "${1:-help}" in
    start)
        start_traffic
        ;;
    stop)
        stop_traffic
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Commande invalide: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
