# Guide complet des Exports CDT Chat

Ce document décrit toutes les fonctions d'export disponibles pour utiliser le système de chat depuis d'autres ressources.

---

## Exports Client

Les exports client permettent de gérer le chat et d'interagir avec lui depuis le côté joueur.

### 1. **openChat()**

Ouvre le chat.

```lua
local chatResource = GetResourceByFindingExport('openChat')
exports[chatResource]:openChat()

-- Ou directement:
exports.chat:openChat()
```

---

### 2. **closeChat()**

Ferme le chat.

```lua
exports.chat:closeChat()
```

---

### 3. **isChatActive()**

Vérifie si le chat est actuellement ouvert.

```lua
local isOpen = exports.chat:isChatActive()
if isOpen then
    print("Le chat est ouvert")
end
```

---

### 4. **isMuted()**

Vérifie si le joueur est actuellement mute.

```lua
local muted = exports.chat:isMuted()
if muted then
    print("Le joueur est mute")
end
```

---

### 5. **getMuteTimeRemaining()**

Récupère le temps de mute restant en secondes.

```lua
local timeRemaining = exports.chat:getMuteTimeRemaining()
print("Temps mute restant: " .. timeRemaining .. " secondes")
```

---

### 6. **hasAnnouncePermission()**

Vérifie si le joueur a la permission d'envoyer des annonces.

```lua
local hasPermission = exports.chat:hasAnnouncePermission()
if hasPermission then
    print("Le joueur peut envoyer des annonces")
end
```

---

### 7. **isAdmin()**

Vérifie si le joueur est administrateur.

```lua
local isAdmin = exports.chat:isAdmin()
if isAdmin then
    print("Le joueur est administrateur")
end
```

---

### 8. **sendMe(message)**

Envoie une action /me.

```lua
exports.chat:sendMe("se gratte la tête")
```

---

### 9. **sendDo(message)**

Envoie une description /do.

```lua
exports.chat:sendDo("Une explosion retentit au loin")
```

---

### 10. **sendAnnouncement(message)**

Envoie une annonce à tous les joueurs (si permission).

```lua
exports.chat:sendAnnouncement("Redémarrage du serveur dans 5 minutes!")
```

---

### 11. **addMessage(source, message)**

Ajoute un message au chat local du joueur.

```lua
exports.chat:addMessage("SYSTEM", "Ceci est un message système")
exports.chat:addMessage("ADMIN", "Message administrateur")
```

---

### 12. **getPlayerMuteStatus(callback)**

Récupère l'état du mute avec un callback.

```lua
exports.chat:getPlayerMuteStatus(function(isMuted, timeRemaining)
    print("Mute: " .. tostring(isMuted))
    print("Temps restant: " .. timeRemaining .. "s")
end)
```

---

## Exports Serveur

Les exports serveur permettent de contrôler le chat depuis le côté serveur.

### 1. **sendSimpleAnnouncement(message, targets)**

Envoie une annonce simple à des joueurs spécifiques ou à tous.

```lua
-- À tous les joueurs
exports.chat:sendSimpleAnnouncement("Maintenance prévue à 22h00")

-- À des joueurs spécifiques (array)
exports.chat:sendSimpleAnnouncement("Message privé", {1, 2, 3})

-- À un joueur spécifique
exports.chat:sendSimpleAnnouncement("Message personnel", 1)
```

---

### 2. **sendAdvancedAnnouncement(data, targets)**

Envoie une annonce formatée avec styles avancés.

```lua
exports.chat:sendAdvancedAnnouncement({
    message = "Important!",
    importance = 'warning',
    duration = 10,
    formatting = {
        bold = true,
        italic = false,
        underline = false,
        color = '#ff0000'
    }
}, 'all')

-- À un joueur spécifique
exports.chat:sendAdvancedAnnouncement({
    message = "Bienvenue sur le serveur!",
    importance = 'info',
    duration = 5,
    formatting = {
        bold = false,
        color = '#00ff00'
    }
}, 42)
```

---

### 3. **mutePlayer(playerId, duration, reason)**

Mute un joueur pour une durée spécifiée.

```lua
exports.chat:mutePlayer(42, 30, "Spam excessif")

-- Avec durée par défaut (config)
exports.chat:mutePlayer(42, nil, "Langage inapproprié")
```

**Paramètres:**
- `playerId` (number) - ID du joueur
- `duration` (number) - Durée en minutes (optionnel)
- `reason` (string) - Raison du mute

---

### 4. **unmutePlayer(playerId)**

Démute un joueur.

```lua
exports.chat:unmutePlayer(42)
```

---

### 5. **getPlayerMuteStatus(playerId, callback)**

Récupère l'état du mute d'un joueur.

```lua
exports.chat:getPlayerMuteStatus(42, function(isMuted, timeRemaining)
    if isMuted then
        print("Joueur est mute pour " .. timeRemaining .. " secondes")
    else
        print("Joueur n'est pas mute")
    end
end)
```

---

### 6. **getPlayerHistory(playerId, limit, callback)**

Récupère l'historique des messages d'un joueur.

```lua
exports.chat:getPlayerHistory(42, 50, function(history)
    for _, msg in ipairs(history) do
        print(msg.player_name .. ": " .. msg.message)
    end
end)
```

---

### 7. **getPlayerHistoryByIdentifier(identifier, limit, callback)**

Récupère l'historique par identifiant de joueur (utile pour les alt accounts).

```lua
exports.chat:getPlayerHistoryByIdentifier('steam:110000123456789', 100, function(history)
    print("Historique trouvé: " .. #history .. " messages")
end)
```

---

### 8. **checkBlockedWords(message)**

Vérifie si un message contient des mots bloqués.

```lua
local hasBlocked, blockedWord = exports.chat:checkBlockedWords("Je voudrais un /give")

if hasBlocked then
    print("Mot bloqué trouvé: " .. blockedWord)
end
```

---

### 9. **addMessageToHistory(playerId, playerName, message)**

Ajoute manuellement un message à l'historique.

```lua
exports.chat:addMessageToHistory(42, "Player Name", "Ceci est un message personnalisé")
```

---

### 10. **registerChatCommandHandler(commandName, callback)**

Enregistre un handler pour une commande chat personnalisée.

```lua
exports.chat:registerChatCommandHandler('customcmd', function(playerId, command)
    exports.chat:sendChatMessage(playerId, 'CUSTOM', 'Commande personnalisée exécutée!')
end)

-- L'utilisateur peut ensuite faire: /customcmd
```

---

### 11. **sendChatMessage(playerId, source, message)**

Envoie un message privé à un joueur.

```lua
exports.chat:sendChatMessage(42, 'SYSTEM', 'Bienvenue sur le serveur!')
exports.chat:sendChatMessage(42, 'ADMIN', 'Tu es maintenant admin')
```

---

### 12. **broadcastChatMessage(source, message)**

Envoie un message à tous les joueurs.

```lua
exports.chat:broadcastChatMessage('SERVER', 'Le serveur redémarre dans 5 minutes!')
```

---

### 13. **sendSystemMessage(messageType, messageText, importance)**

Envoie un message système aux administrateurs.

```lua
exports.chat:sendSystemMessage('commands', 'Joueur 42 a exécuté la commande /tp', 'info')
exports.chat:sendSystemMessage('warnings', 'Trop de mutes rapides détectés', 'warning')
exports.chat:sendSystemMessage('errors', 'Erreur de base de données', 'error')
```

**Types disponibles:**
- `'commands'` - Messages de commandes
- `'warnings'` - Messages d'avertissement
- `'errors'` - Messages d'erreur
- `'info'` - Messages informatifs

**Importances:**
- `'info'` - Informatif
- `'warning'` - Avertissement
- `'error'` - Erreur critique

---

### 14. **getOnlinePlayers()**

Récupère la liste de tous les joueurs en ligne.

```lua
local players = exports.chat:getOnlinePlayers()

for _, player in ipairs(players) do
    print(player.id .. " - " .. player.name .. " (" .. player.identifier .. ")")
end
```

Structure retournée:
```lua
{
    {
        id = 1,
        name = "Player Name",
        identifier = "steam:110000123456789"
    },
    ...
}
```

---

### 15. **isPlayerMuted(playerId, callback)**

Vérifie si un joueur est mute (avec callback).

```lua
exports.chat:isPlayerMuted(42, function(isMuted, timeRemaining)
    if isMuted then
        print("Joueur est mute pour " .. timeRemaining .. "s")
    end
end)
```

---

## Exemples d'utilisation complets

### Exemple 1: Système de rôle avec annonce

```lua
-- Dans votre ressource de gestion des rôles
RegisterCommand('promoteadmin', function(source, args, rawCommand)
    local playerId = tonumber(args[1])
    
    if playerId then
        -- Envoyer une annonce formatée
        exports.chat:sendAdvancedAnnouncement({
            message = GetPlayerName(playerId) .. " est maintenant administrateur!",
            importance = 'warning',
            duration = 10,
            formatting = {
                bold = true,
                color = '#ff6b35'
            }
        }, 'all')
        
        -- Message système aux admins
        exports.chat:sendSystemMessage('info', 'Joueur ' .. playerId .. ' promu administrateur')
    end
end, false)
```

### Exemple 2: Système de modération avancé

```lua
-- Dans votre ressource de modération
local function handleInfraction(playerId, infractions)
    if infractions >= 3 then
        exports.chat:mutePlayer(playerId, 60, "Trop d'infractions")
        exports.chat:sendSystemMessage('warnings', 'Joueur ' .. playerId .. ' a été mute (3+ infractions)', 'warning')
    elseif infractions >= 1 then
        exports.chat:mutePlayer(playerId, 30, "Avertissement: infraction")
    end
end
```

### Exemple 3: Vérification avant envoi de message

```lua
-- Dans votre middleware de chat
exports.chat:registerChatCommandHandler('verify', function(playerId, command)
    local hasBlocked, word = exports.chat:checkBlockedWords(command)
    
    if hasBlocked then
        exports.chat:sendChatMessage(playerId, 'SYSTEM', 'Ce message contient un mot interdit: ' .. word)
    else
        exports.chat:addMessageToHistory(playerId, GetPlayerName(playerId), command)
    end
end)
```

### Exemple 4: Panel personnalisé avec historique

```lua
RegisterCommand('playerinfo', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    if not targetId then return end
    
    exports.chat:getPlayerHistory(targetId, 10, function(history)
        exports.chat:sendChatMessage(source, 'PLAYER_INFO', 'Historique de ' .. GetPlayerName(targetId))
        for _, msg in ipairs(history) do
            exports.chat:sendChatMessage(source, 'MSG', msg.message)
        end
    end)
    
    exports.chat:isPlayerMuted(targetId, function(isMuted, timeRemaining)
        local status = isMuted and ('Mute: ' .. timeRemaining .. 's restant') or 'Non mute'
        exports.chat:sendChatMessage(source, 'STATUS', status)
    end)
end, false)
```

---

## Messages d'erreur courants

### "Cette ressource n'existe pas"
```lua
-- Erreur: La ressource 'chat' n'est pas chargée
-- Solution: Assurez-vous que le nom de la ressource est correct et qu'elle est bien lancée
```

### "Export non trouvé"
```lua
-- Erreur: L'export n'existe pas
-- Solution: Vérifiez l'orthographe du nom de la fonction
```

---

## Bonnes pratiques

1. **Toujours vérifier les permissions avant les actions d'admin**
   ```lua
   if IsPlayerAceAllowed(source, 'chat.admin') then
       -- Action admin
   end
   ```

2. **Utiliser les callbacks pour les opérations async**
   ```lua
   exports.chat:getPlayerHistory(playerId, 50, function(history)
       -- Traiter les données ici
   end)
   ```

3. **Valider les inputs avant d'appeler les exports**
   ```lua
   if playerId and tonumber(playerId) then
       exports.chat:mutePlayer(playerId, 30, "Raison")
   end
   ```

4. **Toujours fournir une raison pour les mutes**
   ```lua
   exports.chat:mutePlayer(playerId, duration, "Raison documentée")
   ```

---

## Dépannage

### Les exports ne fonctionnent pas
1. Assurez-vous que la ressource `chat` est démarrée: `ensure chat`
2. Vérifiez que la ressource `oxmysql` est also chargée (requise pour les fonctions DB)
3. Consultez les logs du serveur pour les erreurs

### Les mutes ne persistent pas
- Vérifiez que `oxmysql` fonctionne correctement
- Vérifiez que `Config.Database.Enabled = true` dans `config.lua`

### Les annonces n'apparaissent pas
- Assurez-vous que les joueurs ont le NUI accessible
- Vérifiez les logs du navigateur (F8)
