#!/usr/bin/env python3
"""
Générateur de messages personnalisés pour les groupes d'étudiants
TP Minecraft - Observabilité
"""

import random
import os
from datetime import datetime

# Templates de messages pour le Groupe 1 (ton formel)
groupe1_templates = {
    "introductions": [
        "Bonjour Groupe 1,",
        "Chers étudiants du Groupe 1,",
        "Salutations Groupe 1,",
        "Bonjour à tous du Groupe 1,"
    ],
    
    "presentations_tp": [
        "Je vous propose aujourd'hui une alternative pédagogique intéressante pour notre cours d'observabilité.",
        "Après réflexion, j'ai développé une approche alternative qui devrait mieux correspondre à vos besoins d'apprentissage.",
        "Je souhaite vous présenter une nouvelle approche pour notre module d'observabilité.",
        "J'ai préparé une alternative pédagogique qui devrait enrichir votre expérience d'apprentissage."
    ],
    
    "descriptions_minecraft": [
        "un TP ludique centré sur l'installation et le monitoring d'un serveur Minecraft",
        "une approche pratique utilisant un serveur Minecraft comme cas d'usage",
        "un projet concret basé sur la mise en place d'un serveur Minecraft avec monitoring",
        "une alternative pratique utilisant Minecraft comme plateforme d'apprentissage"
    ],
    
    "technologies": [
        "Terraform pour l'infrastructure, Ansible pour la configuration, et Prometheus/Grafana pour le monitoring",
        "les technologies modernes d'infrastructure as code et d'observabilité",
        "un stack technique complet : Terraform, Ansible, Prometheus et Grafana",
        "les outils professionnels d'orchestration et de monitoring"
    ],
    
    "benefices": [
        "Cette approche vous permettra de comprendre concrètement les concepts d'observabilité",
        "Vous développerez une compréhension pratique des métriques et du monitoring",
        "Cette méthode vous offrira une expérience hands-on avec les outils d'observabilité",
        "Vous acquerrez une expertise pratique en monitoring et visualisation de données"
    ],
    
    "gestion_difficultes": [
        "Concernant les difficultés techniques rencontrées, je vous accompagnerai dans la résolution des problèmes GCP",
        "Pour les questions liées aux crédits et à la configuration GCP, je fournirai un support détaillé",
        "Je vous guiderai pas à pas dans la configuration de votre environnement GCP",
        "Tous les aspects techniques, y compris la gestion des crédits et des clés SSH, seront couverts"
    ],
    
    "groupes": [
        "Je vous encourage à constituer des groupes de travail pour optimiser votre apprentissage",
        "La constitution d'équipes de travail vous permettra de mutualiser vos compétences",
        "Je recommande fortement le travail en groupe pour enrichir votre expérience",
        "L'approche collaborative vous offrira une meilleure compréhension des concepts"
    ],
    
    "flexibilite": [
        "L'important n'est pas de respecter à la lettre tous les screenshots, mais de démontrer votre compréhension",
        "Je privilégie la compréhension des concepts plutôt que la conformité parfaite aux instructions",
        "L'objectif principal est de valider votre maîtrise des technologies, pas la perfection formelle",
        "Ce qui compte vraiment, c'est votre capacité à évoluer dans la solution et à comprendre les mécanismes"
    ],
    
    "conclusions": [
        "Je reste à votre disposition pour toute question et vous souhaite un excellent travail.",
        "N'hésitez pas à me solliciter pour tout éclaircissement nécessaire.",
        "Je vous accompagnerai tout au long de ce projet et reste disponible pour vos questions.",
        "Bon courage pour ce projet et n'hésitez pas à me faire part de vos difficultés."
    ]
}

# Templates de messages pour le Groupe 2 (ton décontracté)
groupe2_templates = {
    "introductions": [
        "Salut Groupe 2 ! 👋",
        "Hey Groupe 2 ! 🎮",
        "Coucou Groupe 2 ! 😊",
        "Salut tout le monde du Groupe 2 ! 🚀"
    ],
    
    "presentations_tp": [
        "J'ai une super nouvelle pour vous ! J'ai préparé quelque chose de beaucoup plus fun pour notre cours d'observabilité !",
        "Alors, j'ai réfléchi et je vous propose quelque chose de vraiment cool pour remplacer le TP classique !",
        "Bonne nouvelle ! J'ai trouvé une alternative beaucoup plus sympa pour notre module d'observabilité !",
        "Hey ! J'ai une idée géniale pour rendre notre cours d'observabilité beaucoup plus amusant !"
    ],
    
    "descriptions_minecraft": [
        "un TP super fun avec un serveur Minecraft qu'on va monitorer ensemble !",
        "une approche ludique où on va installer et surveiller un serveur Minecraft !",
        "un projet cool basé sur Minecraft avec plein de monitoring et de graphiques !",
        "une alternative géniale utilisant Minecraft comme terrain de jeu pour apprendre !"
    ],
    
    "technologies": [
        "Terraform, Ansible, Prometheus et Grafana - mais de manière super accessible !",
        "les mêmes outils pro, mais présentés de façon beaucoup plus fun !",
        "un stack technique complet, mais on va s'amuser en apprenant !",
        "tous les outils d'infrastructure et de monitoring, mais version ludique !"
    ],
    
    "benefices": [
        "Vous allez apprendre l'observabilité en vous amusant avec Minecraft !",
        "C'est beaucoup plus cool d'apprendre en monitorant un jeu qu'on connaît !",
        "Vous allez comprendre le monitoring de façon concrète et fun !",
        "C'est l'occasion parfaite d'apprendre en s'amusant avec quelque chose qu'on aime !"
    ],
    
    "gestion_difficultes": [
        "Pas de stress pour les problèmes GCP ! Je vais vous aider à tout configurer étape par étape !",
        "Pour les crédits et la config GCP, on va tout faire ensemble, pas de panique !",
        "Je vais vous montrer exactement sur quels boutons appuyer pour GCP !",
        "Tous les trucs techniques GCP, on va les faire ensemble, c'est promis !"
    ],
    
    "groupes": [
        "Je vous encourage à bosser en équipe, c'est beaucoup plus fun et efficace !",
        "Faites des groupes, entraidez-vous, c'est comme ça qu'on apprend le mieux !",
        "Le travail en équipe, c'est la clé ! Vous allez vous éclater ensemble !",
        "Constituer des groupes, c'est top ! Vous allez vous motiver mutuellement !"
    ],
    
    "flexibilite": [
        "L'important, c'est que vous compreniez et que ça marche ! Pas besoin de tout faire parfaitement !",
        "Ce qui compte, c'est que vous voyiez que ça fonctionne et que vous compreniez !",
        "Pas de stress sur les détails ! L'essentiel, c'est la compréhension !",
        "L'objectif, c'est que vous maîtrisiez les concepts, pas la perfection !"
    ],
    
    "conclusions": [
        "Allez, on va s'éclater avec ce projet ! N'hésitez pas si vous avez des questions ! 🎉",
        "C'est parti pour un TP génial ! Je suis là si vous avez besoin d'aide ! 🚀",
        "On va passer un super moment ensemble ! À vos marques, prêts, partez ! 🎮",
        "C'est l'heure de s'amuser en apprenant ! Go go go ! 💪"
    ]
}

def generate_message(groupe_num):
    """Génère un message personnalisé pour le groupe spécifié"""
    
    if groupe_num == 1:
        templates = groupe1_templates
        signature = "Cordialement,\n[Votre nom]"
    else:
        templates = groupe2_templates
        signature = "À bientôt ! 🎮\n[Votre nom]"
    
    # Sélection aléatoire des éléments
    introduction = random.choice(templates["introductions"])
    presentation = random.choice(templates["presentations_tp"])
    description = random.choice(templates["descriptions_minecraft"])
    technologie = random.choice(templates["technologies"])
    benefice = random.choice(templates["benefices"])
    difficulte = random.choice(templates["gestion_difficultes"])
    groupe = random.choice(templates["groupes"])
    flexibilite = random.choice(templates["flexibilite"])
    conclusion = random.choice(templates["conclusions"])
    
    # Construction du message
    message = f"""{introduction}

{presentation} Il s'agit de {description}.

Nous utiliserons {technologie}. {benefice}.

{difficulte} Je vous fournirai un tutoriel détaillé pour vous montrer exactement comment procéder, afin que vous ne soyez pas bloqués lors de la réalisation du TP.

{groupe} Vous me rendrez des TP individuels, mais je saurai que c'est un travail collaboratif. N'oubliez pas de me communiquer la constitution de vos groupes.

    {flexibilite} Ce qui m'intéresse vraiment, c'est de voir dans vos screenshots que ça fonctionne pour vous et que vous avez bien compris les concepts. Il n'y a pas besoin de respecter tous les screenshots demandés, il faut vraiment me montrer que vous savez faire les choses et que vous pouvez évoluer dans la solution.

{conclusion}

{signature}"""
    
    return message

def main():
    """Fonction principale"""
    print("🎮 Générateur de messages pour TP Minecraft - Observabilité")
    print("=" * 60)
    
    # Création du répertoire messages s'il n'existe pas
    os.makedirs("messages", exist_ok=True)
    
    # Génération des messages
    for groupe in [1, 2]:
        message = generate_message(groupe)
        
        # Sauvegarde du message
        filename = f"messages/message_groupe_{groupe}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(f"# Message pour le Groupe {groupe} - TP Minecraft Observabilité\n\n")
            f.write(f"**Généré le :** {datetime.now().strftime('%d/%m/%Y à %H:%M:%S')}\n\n")
            f.write("---\n\n")
            f.write(message)
        
        print(f"✅ Message pour le Groupe {groupe} généré : {filename}")
    
    print("\n🎉 Messages générés avec succès !")
    print("Vous pouvez maintenant les personnaliser et les envoyer à vos étudiants.")

if __name__ == "__main__":
    main()
