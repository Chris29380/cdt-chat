# CDT Custom Chat System

## Description

Le **CDT Custom Chat System** est une ressource FiveM complète et personnalisable qui remplace le système de chat par défaut avec des fonctionnalités avancées.

## Fonctionnalités principales

### Commandes de chat
- **/me** - Affiche une action à proximité (ex: `/me se gratte la tête`)
- **/do** - Affiche une description environnementale (ex: `/do La porte s'ouvre`)
- **/annonce** - Envoie une annonce à tous les joueurs (permission requise)

### Système de modération
- **Mute/Unmute** - Système de silence pour les joueurs (stockage persistant)
- **Filtre de mots bloqués** - Détection automatique et sanction
- **Historique de chat** - Enregistrement complet des messages en base de données

### Panel administrateur
- **Gestion des mutes** - Interface pour mute/unmute les joueurs
- **Historique** - Consulter l'historique des messages
- **Annonces avancées** - Envoyer des annonces formatées avec styles

### Support multilingue
- Français (FR)
- Anglais (EN)
- Allemand (DE)
- Espagnol (ES)
- Portugais (PT)

### Interface utilisateur
- Chat redimensionnable
- Position configurable (coin, centre, bas)
- Annonces avec système de notification
- Affichage des messages /me et /do au-dessus des joueurs

## Architecture

### Structure des fichiers
```
chat/
├── client/
│   ├── cl_chat.lua          # Logique client principal
│   └── cl_suggestions.lua   # Système de suggestions
├── server/
│   └── sv_chat.lua          # Logique serveur principal
├── html/
│   ├── index.html           # Interface utilisateur
│   ├── css/styles.css       # Stylisation
│   └── js/                  # Logique frontend
├── config.lua               # Configuration complète
└── fxmanifest.lua          # Manifeste FiveM
```

## Dépendances

- **oxmysql** - Pour les fonctionnalités de base de données (historique, mutes)

## Configuration

Toutes les configurations se font dans `config.lua` :
- Dimensions et position du chat
- Permissions ACE requises
- Textes et messages multilingues
- Paramètres du système de mute
- Mots bloqués
- Options de stockage en base de données

## Auteur

**CDT** - ChrisToF#0851

Version: 1.0.0
