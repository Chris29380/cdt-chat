# Recommandations d'utilisation

## Configuration recommandée

### Position et dimensions

Pour une meilleure expérience utilisateur, nous recommandons :

```lua
Config.Chat = {
    Position = {
        x = 'left',      -- Chat sur la gauche (zone non-intrusive)
        y = 'center'     -- Vertically centered
    },
    Width = 400,        -- Largeur standard lisible
    MaxHeight = 500     -- Hauteur adaptée aux longs messages
}
```

---

## Système de mute

### Configuration du mute automatique

Pour éviter les abus, nous recommandons :

```lua
Config.Mute = {
    Enabled = true,
    DefaultDuration = 30,           -- 30 minutes par défaut
    PersistentStorage = true        -- Conserver les données
}

Config.BlockedWordsConfig = {
    MuteDuration = 10,              -- 10 minutes pour mots bloqués
    CaseSensitive = false,          -- Ignorer la casse
    Enabled = true
}
```

### Utilisation des mots bloqués

Adaptez la liste `BlockedWords` à votre serveur. Par défaut, elle inclut les commandes Minecraft pour éviter les tentatives d'exploitation.

```lua
Config.BlockedWords = {
    '/stop',            -- Commandes serveur
    '/restart',
    '/quit',
    'bypass',           -- Mots suspects
    'exploit',
    'cheat',
    'hack'
}
```

---

## Permissions et sécurité

### Structure recommandée d'ACE

Organisez vos permissions dans `server.cfg` :

```
# Groupe Admin
add_ace group.admin admin.announce allow
add_ace group.admin chat.admin allow

# Groupe Modérateur
add_ace group.moderator chat.admin allow

# Joueur spécifique
add_ace identifier.fivem:abc123 admin.announce allow
```

### Vérification des permissions

Le système vérifie automatiquement les ACE pour :
- **admin.announce** - Autorisation pour `/annonce`
- **chat.admin** - Accès au panel admin et commandes de modération

---

## Base de données

### Optimisation de la base de données

Pour les serveurs avec beaucoup de joueurs :

```lua
Config.Database = {
    Enabled = true,
    
    History = {
        Enabled = true,
        RecordAllMessages = true,      -- Enregistrer tous les messages
        RecordCommands = true,         -- Inclure les commandes
        Limit = 100                    -- Limiter par joueur (économise de l'espace)
    },
    
    AdminPanel = {
        HistoryLimit = 30              -- Afficher les 30 derniers messages
    }
}
```

### Maintenance de la base de données

Nettoyez régulièrement l'historique ancien :

```sql
-- Supprimer les messages de plus de 30 jours
DELETE FROM chat_history 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Supprimer les anciens mutes
DELETE FROM player_mutes 
WHERE expires_at < NOW();
```

---

## Multilingue

### Configuration de langue

Définissez la langue par défaut pour votre serveur :

```lua
Config.Language = {
    Default = 'fr',              -- Français par défaut
    Available = {'fr', 'en', 'de', 'es', 'pt'}
}
```

Pour personnaliser les messages, éditez `Config.Messages` dans `config.lua`.

---

## UI et UX

### Paramètres visuels recommandés

```lua
Config.Chat.Styling = {
    BorderRadius = 4,
    EditableBorderColor = '#ff6b35',    -- Couleur personnalisée
    ResizeHandleColor = '#ff6b35',
    ResizeHandleOpacity = 0.7,
    ResizeHandleWidth = 8
}
```

### Annonces

Pour les annonces importantes, utilisez la version avancée :

```lua
exports.chat:sendAdvancedAnnouncement({
    importance = 'warning',
    message = 'Message important',
    duration = 10,
    formatting = {
        bold = true,
        color = '#ff0000'
    }
}, 'all')
```

---

## Performance

### Conseils d'optimisation

1. **Limiter l'historique** - Ne conservez que 100 messages par joueur
2. **Désactiver les logs de débogage** :
   ```lua
   Config.Debug = {
       Enabled = false,
       PrintDatabaseQueries = false
   }
   ```
3. **Refresh interval du panel admin** - Ajustez selon vos besoins
4. **Plage de portée des commandes** :
   ```lua
   Config.MeCommand.Range = 50.0       -- 50 unités
   Config.DoCommand.Range = 50.0
   ```

---

## Modération

### Bonnes pratiques

1. **Communiquez les règles** - Prévenez les joueurs des mots interdits
2. **Utilisez des durées graduées** :
   - Première infraction: 10 minutes
   - Deuxième: 30 minutes
   - Troisième: 1 heure
3. **Documentez les mutes** - Gardez trace des raisons
4. **Utilisez le panel admin** - Pour une gestion centralisée

### Commandes importantes

```
/mute <id> <minutes> <raison>      # Mute un joueur
/unmute <id>                         # Demute un joueur
/chathistory                         # Consulter l'historique
/adminchat                          # Ouvrir le panel admin
```

---

## Intégration avec d'autres ressources

### Vérifier le statut de mute des joueurs

Pour intégrer le système de mute avec d'autres ressources, utilisez les exports disponibles:

```lua
-- Vérifier si un joueur est mute
exports.chat:isPlayerMuted(playerId, function(isMuted, timeRemaining)
    if isMuted then
        print("Joueur est mute pour " .. timeRemaining .. "s")
    else
        print("Joueur n'est pas mute")
    end
end)

-- Appliquer un mute
exports.chat:mutePlayer(playerId, 30, "Raison du mute")

-- Retirer un mute
exports.chat:unmutePlayer(playerId)
```

### Exemples d'utilisation

**Système de karma:**
```lua
-- Augmenter les infractions
TriggerEvent('karma:addInfraction', playerId, 'chat_blocked_word')
```

**Système de logs:**
```lua
-- Enregistrer les annonces importantes
TriggerEvent('logs:addLog', {
    type = 'announcement',
    admin_id = adminId,
    message = announcementMessage,
    timestamp = os.time()
})
```

---

## Support et debugging

### Activer le mode debug

Pour le développement :

```lua
Config.Debug = {
    Enabled = true,
    PrintInitialization = true,
    PrintDatabaseQueries = true,
    PrintPermissions = true
}
```

### Troubleshooting

| Problème | Solution |
|----------|----------|
| Chat ne s'ouvre pas | Vérifiez la touche `OpenKey` et les conflits |
| Permissions ne fonctionnent pas | Vérifiez les ACE avec `/id` |
| Mutes ne persistent pas | Assurez-vous que `oxmysql` fonctionne |
| Annonces ne s'affichent pas | Vérifiez la permission `admin.announce` |

---

## Mise à jour et maintenance

### Points de vérification réguliers

- [ ] Nettoyer la base de données (historique)
- [ ] Vérifier les mutes expirés
- [ ] Revoir les mots bloqués
- [ ] Analyser les logs pour les abus
- [ ] Mettre à jour les permissions des admins

### Sauvegarde

Sauvegardez régulièrement :
- Votre `config.lua` personnalisée
- Votre base de données (tables `chat_history` et `player_mutes`)
