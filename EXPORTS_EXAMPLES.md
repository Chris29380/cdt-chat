# Exemples d'utilisation des Exports

## Index des exemples

- [Exemples Client](#exemples-client)
- [Exemples Serveur](#exemples-serveur)
- [Cas d'usage avancés](#cas-dusage-avancés)

---

## Exemples Client

### 1. Système de notification personnalisé

```lua
-- Dans votre ressource client
local function showNotification(title, message)
    exports.chat:addMessage(title, message)
end

RegisterCommand('notify', function(source, args, rawCommand)
    local message = table.concat(args, ' ')
    showNotification('INFO', message)
end, false)
```

### 2. Vérification d'actions dans le chat

```lua
-- Empêcher les actions si mute
RegisterCommand('roleplay', function(source, args, rawCommand)
    if exports.chat:isMuted() then
        exports.chat:addMessage('SYSTEM', 'Vous ne pouvez pas utiliser cette commande (vous êtes mute)')
        return
    end
    
    local message = table.concat(args, ' ')
    exports.chat:sendMe(message)
end, false)
```

### 3. Menu avec status joueur

```lua
-- Interface affichant l'état du joueur
function showPlayerStatus()
    local status = {
        'Chat actif: ' .. tostring(exports.chat:isChatActive()),
        'Mute: ' .. tostring(exports.chat:isMuted()),
        'Admin: ' .. tostring(exports.chat:isAdmin()),
        'Peut annoncer: ' .. tostring(exports.chat:hasAnnouncePermission())
    }
    
    for _, text in ipairs(status) do
        exports.chat:addMessage('STATUS', text)
    end
end

RegisterCommand('status', showPlayerStatus, false)
```

### 4. Actions de groupe avec feedback

```lua
-- Système d'actions synchronisées
RegisterCommand('groupaction', function(source, args, rawCommand)
    if exports.chat:isMuted() then
        exports.chat:addMessage('SYSTEM', 'Action bloquée: vous êtes mute')
        return
    end
    
    local action = args[1] or 'default'
    local message = args[2] or 'effectue une action'
    
    if action == 'dance' then
        exports.chat:sendMe('danse avec ' .. message)
    elseif action == 'emote' then
        exports.chat:sendDo(message)
    elseif action == 'announce' and exports.chat:hasAnnouncePermission() then
        exports.chat:sendAnnouncement(message)
    else
        exports.chat:addMessage('ERROR', 'Action non valide')
    end
end, false)
```

### 5. Système de duels avec annonces

```lua
-- Dans une ressource de duels
RegisterCommand('duelannounce', function(source, args, rawCommand)
    if not exports.chat:hasAnnouncePermission() then
        exports.chat:addMessage('ERROR', 'Vous n\'avez pas la permission')
        return
    end
    
    local opponent = args[1] or 'quelqu\'un'
    exports.chat:sendMe('invite ' .. opponent .. ' à un duel')
    exports.chat:sendAnnouncement('Duel annoncé!')
end, false)
```

---

## Exemples Serveur

### 1. Système de bienvenue avec annonce

```lua
-- Dans votre script d'événements serveur
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    
    Wait(1000)
    
    local source = source
    
    -- Envoyer une annonce de bienvenue
    exports.chat:sendAdvancedAnnouncement({
        message = name .. ' a rejoint le serveur!',
        importance = 'info',
        duration = 5,
        formatting = {
            bold = false,
            color = '#00ff00'
        }
    }, 'all')
    
    -- Envoyer un message privé de bienvenue
    exports.chat:sendChatMessage(source, 'BIENVENUE', 'Bienvenue ' .. name .. '!')
    
    deferrals.done()
end)
```

### 2. Système de modération progressif

```lua
-- Dans votre script de modération
local playerInfractions = {}

RegisterCommand('infract', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'chat.admin') then return end
    
    local playerId = tonumber(args[1])
    if not playerId then return end
    
    playerInfractions[playerId] = (playerInfractions[playerId] or 0) + 1
    local infractions = playerInfractions[playerId]
    
    if infractions == 1 then
        exports.chat:sendChatMessage(playerId, 'ADMIN', 'Avertissement 1/3')
        exports.chat:sendSystemMessage('warnings', 'Joueur ' .. playerId .. ' avertissement 1')
    elseif infractions == 2 then
        exports.chat:mutePlayer(playerId, 15, 'Avertissement 2/3')
        exports.chat:sendSystemMessage('warnings', 'Joueur ' .. playerId .. ' mute 15min (2/3)')
    elseif infractions >= 3 then
        exports.chat:mutePlayer(playerId, 60, 'Avertissement 3/3 - Mute 1h')
        exports.chat:sendSystemMessage('errors', 'Joueur ' .. playerId .. ' mute 1h (3/3)', 'error')
    end
end, false)
```

### 3. Système de tâches avec annonces

```lua
-- Dans une ressource de missions
RegisterCommand('missionstart', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'admin.announce') then return end
    
    local missionName = args[1] or 'Nouvelle mission'
    
    exports.chat:sendAdvancedAnnouncement({
        message = 'Mission: ' .. missionName .. ' est maintenant active!',
        importance = 'warning',
        duration = 8,
        formatting = {
            bold = true,
            italic = false,
            color = '#ff6b35'
        }
    }, 'all')
    
    exports.chat:broadcastChatMessage('MISSION', missionName .. ' a commencé!')
    exports.chat:sendSystemMessage('info', 'Mission lancée: ' .. missionName)
end, false)
```

### 4. Système de logs avec historique

```lua
-- Dans une ressource de logging
RegisterCommand('getplayerlogs', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'chat.admin') then return end
    
    local playerId = tonumber(args[1])
    if not playerId then
        exports.chat:sendChatMessage(source, 'ERROR', 'Syntaxe: /getplayerlogs <id>')
        return
    end
    
    local limit = tonumber(args[2]) or 50
    
    exports.chat:getPlayerHistory(playerId, limit, function(history)
        if #history == 0 then
            exports.chat:sendChatMessage(source, 'INFO', 'Aucun historique trouvé')
            return
        end
        
        exports.chat:sendChatMessage(source, 'LOG', 'Historique de ' .. GetPlayerName(playerId) .. ' (' .. #history .. ' messages)')
        
        for i, msg in ipairs(history) do
            if i <= 10 then
                exports.chat:sendChatMessage(source, i, msg.message)
            end
        end
    end)
end, false)
```

### 5. Gestionnaire de commandes personnalisées

```lua
-- Dans votre script principal
local customCommands = {
    ['support'] = function(playerId, args)
        exports.chat:sendChatMessage(playerId, 'SUPPORT', 'Contactez: support@server.com')
        exports.chat:sendSystemMessage('info', 'Joueur ' .. playerId .. ' a consulté la page support')
    end,
    
    ['rules'] = function(playerId, args)
        exports.chat:broadcastChatMessage('RULES', 'Consultez les règles: /rules')
    end,
    
    ['ip'] = function(playerId, args)
        local ip = GetPlayerEndpoint(playerId)
        exports.chat:sendChatMessage(playerId, 'INFO', 'IP Serveur: 127.0.0.1:30120')
    end
}

for cmd, handler in pairs(customCommands) do
    exports.chat:registerChatCommandHandler(cmd, handler)
end
```

### 6. Système de ban avec notification

```lua
-- Dans votre script de ban
RegisterCommand('ban', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'admin.ban') then return end
    
    local playerId = tonumber(args[1])
    local reason = table.concat(args, ' ', 2) or 'Non spécifiée'
    
    if not playerId then return end
    
    local playerName = GetPlayerName(playerId)
    local identifier = GetPlayerIdentifiers(playerId)[1]
    
    -- Envoyer une annonce
    exports.chat:sendAdvancedAnnouncement({
        message = playerName .. ' a été banni du serveur',
        importance = 'error',
        duration = 10,
        formatting = {
            bold = true,
            color = '#ff0000'
        }
    }, 'all')
    
    -- Message système aux admins
    exports.chat:sendSystemMessage('errors', 'Joueur ' .. playerName .. ' banni - Raison: ' .. reason, 'error')
    
    -- Logger
    exports.chat:addMessageToHistory(playerId, 'ADMIN', 'BAN - Raison: ' .. reason)
    
    DropPlayer(playerId, reason)
end, false)
```

---

## Cas d'usage avancés

### 1. Système de staff avec niveaux

```lua
-- Gestion des niveaux de staff
local staffLevels = {
    ['chat.admin'] = {
        color = '#00ff00',
        name = 'Admin'
    },
    ['chat.moderator'] = {
        color = '#ffff00',
        name = 'Modérateur'
    },
    ['chat.helper'] = {
        color = '#0000ff',
        name = 'Aide'
    }
}

RegisterCommand('staffannounce', function(source, args, rawCommand)
    local message = table.concat(args, ' ')
    if not message or message == '' then return end
    
    for perm, data in pairs(staffLevels) do
        if IsPlayerAceAllowed(source, perm) then
            exports.chat:sendAdvancedAnnouncement({
                message = '[' .. data.name .. '] ' .. message,
                importance = 'info',
                duration = 7,
                formatting = {
                    bold = true,
                    color = data.color
                }
            }, 'all')
            return
        end
    end
end, false)
```

### 2. Système d'événements serveur

```lua
-- Notifications d'événements
local function logServerEvent(eventName, eventData)
    local message = eventName .. ': ' .. (eventData or 'N/A')
    local importance = string.find(eventName, 'error') and 'error' or 'info'
    
    exports.chat:sendSystemMessage('commands', message, importance)
end

-- Utilisation
logServerEvent('SERVER_START', 'Serveur démarré avec succès')
exports.chat:broadcastChatMessage('SERVER', 'Serveur redémarrage complété')

logServerEvent('DATABASE_ERROR', 'Erreur de connexion base de données')
exports.chat:sendSystemMessage('errors', 'Erreur critique détectée', 'error')
```

### 3. Système de rapport avec evidence

```lua
-- Rapports d'infraction avec historique
RegisterCommand('report', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    if not targetId then
        exports.chat:sendChatMessage(source, 'ERROR', '/report <id> <raison>')
        return
    end
    
    local reason = table.concat(args, ' ', 2) or 'Non spécifiée'
    
    -- Récupérer l'historique du joueur
    exports.chat:getPlayerHistory(targetId, 20, function(history)
        -- Notifier les admins
        local adminPlayers = exports.chat:getOnlinePlayers()
        for _, admin in ipairs(adminPlayers) do
            if IsPlayerAceAllowed(admin.id, 'chat.admin') then
                exports.chat:sendChatMessage(admin.id, 'REPORT', 
                    GetPlayerName(source) .. ' reports ' .. GetPlayerName(targetId))
                exports.chat:sendChatMessage(admin.id, 'REPORT', 'Raison: ' .. reason)
                exports.chat:sendChatMessage(admin.id, 'REPORT', 'Messages (' .. #history .. '): voir logs')
            end
        end
        
        -- Logger le rapport
        exports.chat:addMessageToHistory(source, 'REPORT', 
            'Report: ' .. GetPlayerName(targetId) .. ' - ' .. reason)
    end)
end, false)
```

### 4. Système de backup et restore des mutes

```lua
-- Backup et restore des états de mute
local muteBackup = {}

RegisterCommand('mutebackup', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'admin.backup') then return end
    
    local action = args[1]
    
    if action == 'create' then
        -- Sauvegarder tous les mutes
        local players = exports.chat:getOnlinePlayers()
        for _, player in ipairs(players) do
            exports.chat:getPlayerMuteStatus(player.id, function(isMuted, time)
                if isMuted then
                    muteBackup[player.identifier] = {
                        playerId = player.id,
                        timeRemaining = time
                    }
                end
            end)
        end
        exports.chat:sendSystemMessage('info', 'Backup des mutes créé')
    end
    
    if action == 'restore' then
        -- Restaurer les mutes depuis le backup
        for identifier, data in pairs(muteBackup) do
            exports.chat:mutePlayer(data.playerId, math.ceil(data.timeRemaining / 60), 'Restore backup')
        end
        exports.chat:sendSystemMessage('info', 'Mutes restaurés depuis le backup')
    end
end, false)
```

### 5. Système d'annonces programmées

```lua
-- Annonces répétitives
local announcements = {
    {delay = 60000, message = 'Visitez notre Discord: discord.gg/example'},
    {delay = 120000, message = 'Règles: /rules'},
    {delay = 180000, message = 'Support: /support'}
}

local function scheduleAnnouncements()
    for _, announce in ipairs(announcements) do
        SetTimeout(announce.delay, function()
            exports.chat:sendSimpleAnnouncement(announce.message, 'all')
            scheduleAnnouncements()
        end)
    end
end

-- Démarrer les annonces
if GetResourceState('chat') == 'started' then
    Wait(5000)
    scheduleAnnouncements()
end
```

---

## Bonnes pratiques

### ✓ À faire

```lua
-- Valider les données
if playerId and tonumber(playerId) then
    exports.chat:mutePlayer(playerId, 30, 'Raison')
end

-- Utiliser les callbacks pour async
exports.chat:getPlayerHistory(playerId, 50, function(history)
    -- Traiter ici
end)

-- Fournir des raisons détaillées
exports.chat:mutePlayer(playerId, 60, 'Spam excessif de @everyone')

-- Vérifier les permissions
if IsPlayerAceAllowed(source, 'chat.admin') then
    -- Action admin
end
```

### ✗ À éviter

```lua
-- Ne pas supposer les données
exports.chat:mutePlayer(playerId, duration) -- duration peut être nil

-- Ne pas bloquer avec Wait dans les callbacks
exports.chat:getPlayerHistory(playerId, 50, function(history)
    Wait(100) -- ❌ Ne pas faire ça!
end)

-- Ne pas ignorer les erreurs
exports.chat:sendAdvancedAnnouncement(nil) -- Vérifier d'abord

-- Ne pas mélanger async et sync
local history = exports.chat:getPlayerHistory(...) -- Cela ne fonctionnera pas
```
