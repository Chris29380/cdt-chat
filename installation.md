# Guide d'installation

## Prérequis

- FiveM serveur
- Resource **oxmysql** (obligatoire pour les fonctionnalités de base de données)

## Installation

### 1. Placement de la ressource

Placez le dossier `chat` dans votre répertoire `resources` :

```
resources/
├── chat/                    # Cette ressource
├── oxmysql/                 # Dépendance requise
└── ... autres ressources
```

### 2. Configuration du serveur

Ajoutez la ressource au fichier `server.cfg` :

```
ensure oxmysql
ensure chat
```

Assurez-vous que `oxmysql` est chargé **avant** `chat`.

### 3. Configuration des permissions

Configurez les permissions ACE dans votre `server.cfg` selon vos besoins :

```
# Permission pour les annonces
add_ace identifier.fivem:abc123 admin.announce allow
add_ace identifier.fivem:abc123 chat.admin allow

# Ou pour un groupe admin
add_ace group.admin admin.announce allow
add_ace group.admin chat.admin allow
```

### 4. Configuration de la ressource

Éditez `config.lua` pour adapter la ressource à vos besoins :

```lua
Config = {
    Chat = {
        Position = { x = 'left', y = 'center' },  -- Position sur l'écran
        Width = 400,                                 -- Largeur en pixels
        MaxHeight = 500,                             -- Hauteur maximale
        OpenKey = 't'                                -- Touche pour ouvrir
    },
    Permissions = {
        announcementCommand = 'admin.announce',  -- Permission pour /annonce
        adminCommand = 'chat.admin'              -- Permission pour les commandes admin
    },
    -- ... autres configurations
}
```

### 5. Démarrage du serveur

Démarrez votre serveur FiveM. Vous devriez voir :

```
[^2+^7] Starting resource chat
```

En cas d'erreur, vérifiez :
- Que `oxmysql` est chargé correctement
- Que les permissions sont bien configurées
- Les logs du serveur pour plus de détails

## Vérification de l'installation

Une fois en jeu :

1. Appuyez sur **T** pour ouvrir le chat
2. Testez les commandes basiques :
   - `/me exemple` - Devrait afficher au-dessus de votre tête
   - `/do exemple` - Devrait afficher au-dessus de votre tête

## Désinstallation

Pour désinstaller la ressource :

1. Supprimez le dossier `chat` du répertoire `resources`
2. Retirez `ensure chat` du `server.cfg`
3. Redémarrez le serveur

Les données en base de données seront conservées mais inutilisées.

## Troubleshooting

### Le chat ne s'ouvre pas
- Vérifiez que la clé configurée (par défaut 'T') n'est pas en conflit
- Vérifiez les logs pour les erreurs de compilation Lua

### Les mutes ne persistent pas
- Assurez-vous que `oxmysql` est correctement installé
- Vérifiez que `Database.Enabled = true` dans `config.lua`

### Les permissions ne fonctionnent pas
- Vérifiez l'identifiant FiveM du joueur (`/id`)
- Assurez-vous que la permission est ajoutée correctement dans `server.cfg`
