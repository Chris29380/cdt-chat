# Exports Serveur

## Description

Les exports serveur permettent aux autres ressources de contrôler et d'interagir avec le système de chat depuis le côté serveur.

**Total: 15 fonctions d'export**

---

## 1. sendSimpleAnnouncement(message, targets)

**Description:** Envoie une annonce simple à des joueurs

```lua
exports.chat:sendSimpleAnnouncement(message, targets)
```

**Paramètres:**
- `message` (string) - Texte de l'annonce
- `targets` (string|number|table, optionnel) - Cible(s): 'all', ID du joueur ou table d'IDs

**Retour:** void

**Exemple:**
```lua
-- À tous les joueurs
exports.chat:sendSimpleAnnouncement("Maintenance prévue à 22h00")

-- À des joueurs spécifiques
exports.chat:sendSimpleAnnouncement("Message privé", {1, 2, 3})

-- À un joueur spécifique
exports.chat:sendSimpleAnnouncement("Message personnel", 42)
```

---

## 2. sendAdvancedAnnouncement(data, targets)

**Description:** Envoie une annonce formatée avec styles avancés

```lua
exports.chat:sendAdvancedAnnouncement(data, targets)
```

**Paramètres:**
- `data` (table) - Objet d'annonce:
  ```lua
  {
    message = 'Texte',              -- (requis) Texte de l'annonce
    importance = 'info',            -- (optionnel) 'info', 'warning', 'error'
    duration = 5,                   -- (optionnel) Durée en secondes
    formatting = {                  -- (optionnel) Styles
        bold = true,
        italic = false,
        underline = false,
        color = '#ff0000'           -- Couleur hexadécimale
    }
  }
  ```
- `targets` (string|number|table, optionnel) - Même structure que sendSimpleAnnouncement

**Retour:** void

**Exemple:**
```lua
exports.chat:sendAdvancedAnnouncement({
    message = "Important!",
    importance = 'warning',
    duration = 10,
    formatting = {
        bold = true,
        color = '#ff0000'
    }
}, 'all')
```

---

## 3. mutePlayer(playerId, duration, reason)

**Description:** Mute un joueur pour une durée spécifiée

```lua
local success = exports.chat:mutePlayer(playerId, duration, reason)
```

**Paramètres:**
- `playerId` (number) - ID du joueur
- `duration` (number, optionnel) - Durée en minutes (par défaut: config.Mute.DefaultDuration)
- `reason` (string, optionnel) - Raison du mute

**Retour:** `boolean` - true si succès

**Exemple:**
```lua
exports.chat:mutePlayer(42, 30, "Spam excessif")
exports.chat:mutePlayer(42)  -- Utilise la durée par défaut
```

---

## 4. unmutePlayer(playerId)

**Description:** Démute un joueur

```lua
local success = exports.chat:unmutePlayer(playerId)
```

**Paramètres:**
- `playerId` (number) - ID du joueur

**Retour:** `boolean` - true si succès

**Exemple:**
```lua
exports.chat:unmutePlayer(42)
```

---

## 5. getPlayerMuteStatus(playerId, callback)

**Description:** Récupère l'état du mute d'un joueur avec callback

```lua
exports.chat:getPlayerMuteStatus(playerId, callback)
```

**Paramètres:**
- `playerId` (number) - ID du joueur
- `callback` (function) - Fonction appelée avec (isMuted, timeRemaining)

**Retour:** void

**Exemple:**
```lua
exports.chat:getPlayerMuteStatus(42, function(isMuted, timeRemaining)
    if isMuted then
        print("Joueur est mute pour " .. timeRemaining .. "s")
    else
        print("Joueur n'est pas mute")
    end
end)
```

---

## 6. getPlayerHistory(playerId, limit, callback)

**Description:** Récupère l'historique des messages d'un joueur

```lua
exports.chat:getPlayerHistory(playerId, limit, callback)
```

**Paramètres:**
- `playerId` (number) - ID du joueur
- `limit` (number, optionnel) - Nombre max de messages
- `callback` (function) - Fonction appelée avec (history)

**Retour:** void

**Exemple:**
```lua
exports.chat:getPlayerHistory(42, 50, function(history)
    for _, msg in ipairs(history) do
        print(msg.player_name .. ": " .. msg.message)
    end
end)
```

---

## 7. getPlayerHistoryByIdentifier(identifier, limit, callback)

**Description:** Récupère l'historique par identifiant (Steam ID, etc)

```lua
exports.chat:getPlayerHistoryByIdentifier(identifier, limit, callback)
```

**Paramètres:**
- `identifier` (string) - Identifiant du joueur (steam:..., discord:...)
- `limit` (number, optionnel) - Nombre max de messages
- `callback` (function) - Fonction appelée avec (history)

**Retour:** void

**Exemple:**
```lua
exports.chat:getPlayerHistoryByIdentifier('steam:110000123456789', 100, function(history)
    print("Historique trouvé: " .. #history .. " messages")
end)
```

---

## 8. checkBlockedWords(message)

**Description:** Vérifie si un message contient des mots bloqués

```lua
local hasBlocked, blockedWord = exports.chat:checkBlockedWords(message)
```

**Paramètres:**
- `message` (string) - Message à vérifier

**Retour:** `boolean, string` - (true si mot bloqué trouvé, nom du mot bloqué)

**Exemple:**
```lua
local hasBlocked, word = exports.chat:checkBlockedWords("Je voudrais un /give")
if hasBlocked then
    print("Mot bloqué détecté: " .. word)
end
```

---

## 9. addMessageToHistory(playerId, playerName, message)

**Description:** Ajoute manuellement un message à l'historique

```lua
local success = exports.chat:addMessageToHistory(playerId, playerName, message)
```

**Paramètres:**
- `playerId` (number) - ID du joueur
- `playerName` (string) - Nom du joueur
- `message` (string) - Texte du message

**Retour:** `boolean` - true si succès

**Exemple:**
```lua
exports.chat:addMessageToHistory(42, "Player Name", "Ceci est un message enregistré")
```

---

## 10. registerChatCommandHandler(commandName, callback)

**Description:** Enregistre un handler pour une commande chat personnalisée

```lua
local success = exports.chat:registerChatCommandHandler(commandName, callback)
```

**Paramètres:**
- `commandName` (string) - Nom de la commande (sans /)
- `callback` (function) - Fonction(playerId, command)

**Retour:** `boolean` - true si succès

**Exemple:**
```lua
exports.chat:registerChatCommandHandler('customcmd', function(playerId, command)
    TriggerClientEvent('chat:addMessage', playerId, {
        args = {'CUSTOM', 'Commande personnalisée exécutée!'}
    })
end)

-- Utilisateur peut faire: /customcmd
```

---

## 11. sendChatMessage(playerId, source, message)

**Description:** Envoie un message privé à un joueur

```lua
local success = exports.chat:sendChatMessage(playerId, source, message)
```

**Paramètres:**
- `playerId` (number) - ID du joueur
- `source` (string) - Nom de la source (ex: 'SYSTEM', 'ADMIN')
- `message` (string) - Texte du message

**Retour:** `boolean` - true si succès

**Exemple:**
```lua
exports.chat:sendChatMessage(42, 'SYSTEM', 'Bienvenue sur le serveur!')
exports.chat:sendChatMessage(42, 'ADMIN', 'Tu es maintenant admin')
```

---

## 12. broadcastChatMessage(source, message)

**Description:** Envoie un message à tous les joueurs

```lua
local success = exports.chat:broadcastChatMessage(source, message)
```

**Paramètres:**
- `source` (string) - Nom de la source
- `message` (string) - Texte du message

**Retour:** `boolean` - true si succès

**Exemple:**
```lua
exports.chat:broadcastChatMessage('SERVER', 'Le serveur redémarre dans 5 minutes!')
```

---

## 13. sendSystemMessage(messageType, messageText, importance)

**Description:** Envoie un message système aux administrateurs

```lua
local success = exports.chat:sendSystemMessage(messageType, messageText, importance)
```

**Paramètres:**
- `messageType` (string) - Type: 'commands', 'warnings', 'errors', 'info'
- `messageText` (string) - Texte du message
- `importance` (string, optionnel) - 'info', 'warning', 'error'

**Retour:** `boolean` - true si succès

**Exemple:**
```lua
exports.chat:sendSystemMessage('commands', 'Joueur 42 a exécuté /tp', 'info')
exports.chat:sendSystemMessage('warnings', 'Trop de mutes rapides', 'warning')
```

---

## 14. getOnlinePlayers()

**Description:** Récupère la liste de tous les joueurs en ligne

```lua
local players = exports.chat:getOnlinePlayers()
```

**Paramètres:** Aucun

**Retour:** `table` - Liste des joueurs avec structure:
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

**Exemple:**
```lua
local players = exports.chat:getOnlinePlayers()
for _, player in ipairs(players) do
    print(player.id .. " - " .. player.name)
end
```

---

## 15. isPlayerMuted(playerId, callback)

**Description:** Vérifie si un joueur est mute

```lua
exports.chat:isPlayerMuted(playerId, callback)
```

**Paramètres:**
- `playerId` (number) - ID du joueur
- `callback` (function) - Fonction(isMuted, timeRemaining)

**Retour:** void

**Exemple:**
```lua
exports.chat:isPlayerMuted(42, function(isMuted, timeRemaining)
    if isMuted then
        print("Joueur est mute pour " .. timeRemaining .. "s")
    end
end)
```

---

## Utilisation dans d'autres ressources

```lua
-- Envoyer une annonce à tous
exports.chat:sendSimpleAnnouncement("Message important")

-- Mute automatique
exports.chat:mutePlayer(playerId, 30, "Raison")

-- Obtenir les joueurs en ligne
local players = exports.chat:getOnlinePlayers()

-- Vérifier un état
exports.chat:getPlayerHistory(playerId, 50, function(history)
    print("Historique: " .. #history .. " messages")
end)

-- Ajouter une commande personnalisée
exports.chat:registerChatCommandHandler('info', function(playerId, cmd)
    exports.chat:sendChatMessage(playerId, 'INFO', 'Commande info')
end)
```
