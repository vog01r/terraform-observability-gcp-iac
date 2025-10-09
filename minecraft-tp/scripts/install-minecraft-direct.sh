#!/bin/bash
# Installation directe du serveur Minecraft sans LinuxGSM
# Script non-interactif pour éviter les questions

set -euo pipefail

echo "=== Installation directe du serveur Minecraft ==="

# Mise à jour du système
apt-get update
apt-get upgrade -y

# Installation des dépendances
apt-get install -y openjdk-21-jre wget curl unzip

# Création de l'utilisateur mcserver s'il n'existe pas
if ! id "mcserver" &>/dev/null; then
    adduser --disabled-password --gecos "" mcserver
    echo "mcserver:jE5Mzg1NDc3M" | chpasswd
    echo "Utilisateur mcserver créé avec le mot de passe: jE5Mzg1NDc3M"
fi

# Création du répertoire de travail
mkdir -p /home/mcserver/serverfiles
chown -R mcserver:mcserver /home/mcserver

# Téléchargement du serveur Minecraft (Paper pour de meilleures performances)
cd /home/mcserver/serverfiles
wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/1300/downloads/paper-1.20.4-1300.jar

# Création du fichier eula.txt (acceptation automatique)
cat > eula.txt << 'EOF'
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
#Mon Dec 18 10:00:00 UTC 2023
eula=true
EOF

# Création du fichier server.properties avec configuration de base
cat > server.properties << 'EOF'
#Minecraft server properties
server-port=25565
gamemode=survival
difficulty=easy
max-players=20
online-mode=false
white-list=false
motd=TP Minecraft - Observabilité
level-name=world
level-type=minecraft\:normal
enable-command-block=false
allow-nether=true
announce-player-achievements=true
enable-query=false
enable-rcon=false
force-gamemode=false
generate-structures=true
hardcore=false
pvp=true
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=16
view-distance=10
EOF

# Création du script de démarrage
cat > /home/mcserver/start.sh << 'EOF'
#!/bin/bash
cd /home/mcserver/serverfiles
java -Xmx2G -Xms1G -jar paper.jar nogui
EOF

chmod +x /home/mcserver/start.sh
chown -R mcserver:mcserver /home/mcserver

# Création du service systemd
cat > /etc/systemd/system/minecraft.service << 'EOF'
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=mcserver
WorkingDirectory=/home/mcserver/serverfiles
ExecStart=/usr/bin/java -Xmx2G -Xms1G -jar paper.jar nogui
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Rechargement et activation du service
systemctl daemon-reload
systemctl enable minecraft.service

echo "✅ Serveur Minecraft installé avec succès !"
echo "📁 Répertoire: /home/mcserver/serverfiles"
echo "🎮 Port: 25565"
echo "👤 Utilisateur: mcserver"
echo "🔑 Mot de passe: jE5Mzg1NDc3M"
echo ""
echo "Pour démarrer le serveur:"
echo "  sudo systemctl start minecraft"
echo "  sudo systemctl status minecraft"
echo ""
echo "Ou manuellement:"
echo "  su - mcserver"
echo "  cd /home/mcserver/serverfiles"
echo "  java -Xmx2G -Xms1G -jar paper.jar nogui"
