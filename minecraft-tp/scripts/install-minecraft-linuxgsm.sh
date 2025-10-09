#!/bin/bash
# Script d'installation du serveur Minecraft avec LinuxGSM
# Basé sur la documentation LinuxGSM

set -euo pipefail

echo "=== Installation du serveur Minecraft avec LinuxGSM ==="

# Mise à jour du système
echo "Mise à jour du système..."
apt-get update
apt-get upgrade -y

# Installation des dépendances
echo "Installation des dépendances..."
apt-get install -y curl wget unzip

# Création de l'utilisateur mcserver
echo "Création de l'utilisateur mcserver..."
if ! id "mcserver" &>/dev/null; then
    adduser --disabled-password --gecos "" mcserver
    echo "mcserver:jE5Mzg1NDc3M" | chpasswd
    echo "Utilisateur mcserver créé avec le mot de passe: jE5Mzg1NDc3M"
else
    echo "L'utilisateur mcserver existe déjà"
fi

# Passage à l'utilisateur mcserver
echo "Passage à l'utilisateur mcserver..."
su - mcserver << 'EOF'
# Téléchargement et installation de LinuxGSM
echo "Téléchargement de LinuxGSM..."
curl -Lo linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh mcserver

# Installation du serveur Minecraft
echo "Installation du serveur Minecraft..."
./mcserver install

# Configuration du serveur
echo "Configuration du serveur..."
./mcserver details

# Démarrage du serveur
echo "Démarrage du serveur Minecraft..."
./mcserver start

# Vérification du statut
echo "Vérification du statut du serveur..."
./mcserver details

echo "Serveur Minecraft installé et démarré avec succès!"
echo "Pour accéder au serveur:"
echo "- Console: ./mcserver console"
echo "- Arrêt: ./mcserver stop"
echo "- Redémarrage: ./mcserver restart"
echo "- Mise à jour: ./mcserver update"
echo "- Sauvegarde: ./mcserver backup"
echo "- Monitoring: ./mcserver monitor"
EOF

# Installation de Node Exporter pour les métriques
echo "Installation de Node Exporter..."
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xzf node_exporter-1.6.1.linux-amd64.tar.gz
mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.6.1.linux-amd64*

# Création du service Node Exporter
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Démarrage de Node Exporter
systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service

echo "Node Exporter installé et démarré sur le port 9100"

# Configuration des cronjobs pour le monitoring
echo "Configuration des cronjobs..."
crontab -l 2>/dev/null | { cat; echo "*/5 * * * * /home/mcserver/mcserver monitor > /dev/null 2>&1"; } | crontab -
crontab -l 2>/dev/null | { cat; echo "*/30 * * * * /home/mcserver/mcserver update > /dev/null 2>&1"; } | crontab -
crontab -l 2>/dev/null | { cat; echo "0 0 * * 0 /home/mcserver/mcserver update-lgsm > /dev/null 2>&1"; } | crontab -

echo "=== Installation terminée avec succès! ==="
echo "Serveur Minecraft accessible sur le port 25565"
echo "Node Exporter accessible sur le port 9100"
echo "Cronjobs configurés pour le monitoring automatique"
