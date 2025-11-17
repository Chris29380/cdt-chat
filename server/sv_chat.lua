RegisterServerEvent('cdtChat:init')
AddEventHandler('cdtChat:init', function()
    local source = source
    local hasPermission = IsPlayerAceAllowed(source, Config.Permissions.announcementCommand)
    local isAdmin = IsPlayerAceAllowed(source, 'chat.admin')
    TriggerClientEvent('cdtChat:updatePermissions', source, hasPermission, isAdmin)
end)

RegisterServerEvent('cdtChat:getPlayersForAnnounce')
AddEventHandler('cdtChat:getPlayersForAnnounce', function()
    local source = source
    local players = {}
    
    for _, pid in ipairs(GetPlayers()) do
        local playerId = tonumber(pid)
        local playerName = GetPlayerName(playerId)
        if playerName then
            table.insert(players, {
                id = playerId,
                name = playerName
            })
        end
    end
    
    TriggerClientEvent('cdtChat:playersListResponse', source, players)
end)

RegisterServerEvent('cdtChat:meCommand')
AddEventHandler('cdtChat:meCommand', function(message)
    local source = source
    local text = '* ' .. message .. ' *'
    TriggerClientEvent('cdtChat:showMe', -1, text, source)
    TriggerClientEvent('cdtChat:showCommandResult', source, '[ME] * ' .. message .. ' *')
end)

RegisterServerEvent('cdtChat:doCommand')
AddEventHandler('cdtChat:doCommand', function(message)
    local source = source
    local text = message
    TriggerClientEvent('cdtChat:showDo', -1, text, source)
    TriggerClientEvent('cdtChat:showCommandResult', source, '[DO] ' .. text)
end)

RegisterServerEvent('cdtChat:announceCommand')
AddEventHandler('cdtChat:announceCommand', function(message)
    local source = source
    local lang = Config.Language.Default
    local msgs = Config.Messages[lang] or Config.Messages.fr
    
    if not IsPlayerAceAllowed(source, Config.Permissions.announcementCommand) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'SYSTEM', msgs.PermissionDenied}
        })
        return
    end
    
    local msgStr = tostring(message or '')
    for _, pid in ipairs(GetPlayers()) do
        TriggerClientEvent('cdtChat:sendAnnouncement', tonumber(pid), msgStr)
    end
end)

RegisterServerEvent('cdtChat:submitAdvancedAnnounce')
AddEventHandler('cdtChat:submitAdvancedAnnounce', function(data)
    local source = source
    
    print('[submitAdvancedAnnounce] Received data from client')
    print('[submitAdvancedAnnounce] data.message:', data.message, 'type:', type(data.message))
    
    if not IsPlayerAceAllowed(source, Config.Permissions.announcementCommand) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'SYSTEM', msgs.PermissionDenied}
        })
        return
    end
    
    local fmt = data.formatting or {}
    local messageStr = tostring(data.message or '')
    print('[submitAdvancedAnnounce] messageStr after tostring:', messageStr, 'length:', string.len(messageStr))
    
    local announcementData = {
        importance = data.importance or 'info',
        message = messageStr,
        duration = tonumber(data.duration) or 5,
        formatting = {
            bold = fmt.bold == true,
            italic = fmt.italic == true,
            underline = fmt.underline == true,
            color = tostring(fmt.color or Config.Announcement.DefaultFormatting.color)
        }
    }
    
    print('[submitAdvancedAnnounce] Sending announcementData with message:', announcementData.message)
    
    if data.target == 'specific' and data.targetPlayer then
        local targetId = tonumber(data.targetPlayer)
        if targetId then
            TriggerClientEvent('cdtChat:showAdvancedAnnouncement', targetId, announcementData)
        end
    else
        for _, pid in ipairs(GetPlayers()) do
            TriggerClientEvent('cdtChat:showAdvancedAnnouncement', tonumber(pid), announcementData)
        end
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {'SYSTEM', msgs.AnnouncementSent}
    })
end)

local commandHandlers = {}

function RegisterChatCommandHandler(commandName, callback)
    commandHandlers[commandName] = callback
end

RegisterServerEvent('cdtChat:commandExecuted')
AddEventHandler('cdtChat:commandExecuted', function(command)
    local source = source
    local lang = Config.Language.Default
    local msgs = Config.Messages[lang] or Config.Messages.fr
    local commandName = command:match('^/([^ ]+)')
    
    if commandName and commandHandlers[commandName] then
        commandHandlers[commandName](source, command)
    else
        TriggerClientEvent('cdtChat:showCommandResult', source, string.format(msgs.CommandExecuted, command))
    end
end)

RegisterChatCommandHandler('test', function(source, command)
    TriggerClientEvent('chat:addMessage', source, {
        args = {'CONSOLE', 'Développé par CdtFivem - Développeur FullStack - www.cdtfivem.com'}
    })
end)

RegisterChatCommandHandler('help', function(source, command)
    local help = 'Commandes disponibles:\n/test [args] - Commande de test\n/help - Affiche cette aide'
    TriggerClientEvent('cdtChat:showCommandResult', source, '[AIDE]\n' .. help)
end)

if GetResourceState('oxmysql') == 'started' then
    local function initializeDatabase()
        local queries = {
            [[
                CREATE TABLE IF NOT EXISTS player_mutes (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    player_id INT,
                    identifier VARCHAR(100) UNIQUE,
                    muted_until INT,
                    muted_by VARCHAR(50),
                    reason TEXT,
                    muted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX(player_id),
                    INDEX(identifier),
                    INDEX(muted_until)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            ]],
            [[
                CREATE TABLE IF NOT EXISTS chat_history (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    player_id INT,
                    identifier VARCHAR(100),
                    player_name VARCHAR(50),
                    message TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX(player_id),
                    INDEX(identifier),
                    INDEX(created_at)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            ]],
            [[
                CREATE TABLE IF NOT EXISTS chat_zone_settings (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    identifier VARCHAR(100),
                    zone_id VARCHAR(50),
                    color VARCHAR(7),
                    opacity INT,
                    top VARCHAR(50),
                    `left` VARCHAR(50),
                    width VARCHAR(50),
                    height VARCHAR(50),
                    show_auto BOOLEAN DEFAULT TRUE,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    UNIQUE KEY unique_player_zone (identifier, zone_id),
                    INDEX(identifier),
                    INDEX(zone_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            ]],
            [[
                CREATE TABLE IF NOT EXISTS player_settings (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    identifier VARCHAR(100) UNIQUE,
                    language VARCHAR(10) DEFAULT 'fr',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    INDEX(identifier),
                    INDEX(language)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            ]]
        }
        
        for _, query in ipairs(queries) do
            exports.oxmysql:execute(query, {}, function(result) end)
        end
        
        print('^2[Chat] Database initialized successfully^7')
    end
    
    initializeDatabase()
else
    print('^3[Chat] oxmysql not found - database features disabled^7')
end

RegisterServerEvent('_chat:messageEntered')
AddEventHandler('_chat:messageEntered', function(author, color, message, mode)
end)

local function mutePlayer(playerId, duration, reason, mutedByName)
    if GetResourceState('oxmysql') == 'started' then
        local identifier = GetPlayerIdentifiers(playerId)[1] or 'unknown'
        local mutedUntil = os.time() + (duration * 60)
        exports.oxmysql:execute('INSERT INTO player_mutes (player_id, identifier, muted_until, muted_by, reason) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE player_id = ?, muted_until = ?, muted_by = ?, reason = ?, muted_at = NOW()', 
            {playerId, identifier, mutedUntil, mutedByName, reason, playerId, mutedUntil, mutedByName, reason}, function() end)
    end
end

local function unmutePlayer(playerId)
    if GetResourceState('oxmysql') == 'started' then
        local identifier = GetPlayerIdentifiers(playerId)[1] or 'unknown'
        exports.oxmysql:execute('DELETE FROM player_mutes WHERE identifier = ?', {identifier}, function() end)
    end
end

local function getPlayerMuteStatus(playerId, callback)
    if GetResourceState('oxmysql') == 'started' then
        local identifier = GetPlayerIdentifiers(playerId)[1] or 'unknown'
        exports.oxmysql:fetch('SELECT * FROM player_mutes WHERE identifier = ? AND muted_until > ?', {identifier, os.time()}, function(result)
            if result and result[1] then
                callback(true, result[1].muted_until - os.time())
            else
                callback(false, 0)
            end
        end)
    else
        callback(false, 0)
    end
end

local function addMessageToHistory(playerId, playerName, message)
    if GetResourceState('oxmysql') == 'started' then
        local identifier = GetPlayerIdentifiers(playerId)[1] or 'unknown'
        exports.oxmysql:execute('INSERT INTO chat_history (player_id, identifier, player_name, message) VALUES (?, ?, ?, ?)', 
            {playerId, identifier, playerName, message}, function() end)
    end
end

local function getPlayerHistory(playerId, limit, callback)
    if GetResourceState('oxmysql') == 'started' then
        print('^3[DB] Querying history for player ' .. playerId .. '^7')
        exports.oxmysql:fetch('SELECT * FROM chat_history WHERE player_id = ? ORDER BY created_at DESC LIMIT ?', 
            {playerId, limit or Config.Database.History.Limit}, function(result)
            print('^3[DB] Got result for player ' .. playerId .. ' with ' .. (result and #result or 0) .. ' results^7')
            callback(result or {})
        end)
    else
        print('^1[DB] oxmysql not started^7')
        callback({})
    end
end

local function getPlayerHistoryByIdentifier(identifier, limit, callback)
    if GetResourceState('oxmysql') == 'started' then
        print('^3[DB] Querying history for identifier ' .. identifier .. '^7')
        exports.oxmysql:fetch('SELECT * FROM chat_history WHERE identifier = ? ORDER BY created_at DESC LIMIT ?', 
            {identifier, limit or Config.Database.History.Limit}, function(result)
            print('^3[DB] Got result for identifier ' .. identifier .. ' with ' .. (result and #result or 0) .. ' results^7')
            callback(result or {})
        end)
    else
        print('^1[DB] oxmysql not started^7')
        callback({})
    end
end

RegisterNetEvent('cdtChat:checkMuteStatus')
AddEventHandler('cdtChat:checkMuteStatus', function()
    local source = source
    getPlayerMuteStatus(source, function(isMuted, timeRemaining)
        TriggerClientEvent('cdtChat:muteStatusResponse', source, isMuted, timeRemaining)
    end)
end)

local function containsBlockedWord(message)
    if not Config.BlockedWordsConfig.Enabled then
        return false, nil
    end
    
    local messageCheck = message
    if not Config.BlockedWordsConfig.CaseSensitive then
        messageCheck = string.lower(message)
    end
    
    for _, blockedWord in ipairs(Config.BlockedWords) do
        local wordCheck = blockedWord
        if not Config.BlockedWordsConfig.CaseSensitive then
            wordCheck = string.lower(blockedWord)
        end
        if string.find(messageCheck, wordCheck, 1, true) then
            return true, blockedWord
        end
    end
    return false, nil
end

RegisterNetEvent('cdtChat:recordMessage')
AddEventHandler('cdtChat:recordMessage', function(message)
    local source = source
    local playerName = GetPlayerName(source)
    local lang = Config.Language.Default
    local msgs = Config.Messages[lang] or Config.Messages.fr
    
    local hasBlocked, blockedWord = containsBlockedWord(message)
    if hasBlocked then
        local isAdmin = IsPlayerAceAllowed(source, Config.Permissions.adminCommand)
        if not isAdmin then
            mutePlayer(source, Config.BlockedWordsConfig.MuteDuration, string.format(msgs.MuteReason, blockedWord), 'SYSTEM')
            TriggerClientEvent('cdtChat:playerMuted', source, Config.BlockedWordsConfig.MuteDuration)
            TriggerClientEvent('chat:addMessage', source, {
                args = {'SYSTEM', string.format(msgs.AutoMuteMessage, Config.BlockedWordsConfig.MuteDuration)}
            })
            return
        end
    end
    
    addMessageToHistory(source, playerName, message)
end)

RegisterCommand('mute', function(source, args, rawCommand)
    local lang = Config.Language.Default
    local msgs = Config.Messages[lang] or Config.Messages.fr
    
    if IsPlayerAceAllowed(source, Config.Permissions.adminCommand) then
        local targetId = tonumber(args[1])
        local duration = tonumber(args[2]) or Config.Mute.DefaultDuration
        local reason = table.concat(args, ' ', 3) or 'No reason provided'
        
        if targetId then
            local adminName = GetPlayerName(source)
            mutePlayer(targetId, duration, reason, adminName)
            TriggerClientEvent('chat:addMessage', source, {
                args = {'ADMIN', string.format(msgs.MuteAdminMessage, GetPlayerName(targetId), duration)}
            })
            TriggerClientEvent('cdtChat:playerMuted', targetId, duration)
        end
    end
end, false)

RegisterCommand('unmute', function(source, args, rawCommand)
    local lang = Config.Language.Default
    local msgs = Config.Messages[lang] or Config.Messages.fr
    
    if IsPlayerAceAllowed(source, Config.Permissions.adminCommand) then
        local targetId = tonumber(args[1])
        if targetId then
            unmutePlayer(targetId)
            TriggerClientEvent('chat:addMessage', source, {
                args = {'ADMIN', string.format(msgs.UnmuteAdminMessage, GetPlayerName(targetId))}
            })
            TriggerClientEvent('cdtChat:playerUnmuted', targetId)
        end
    end
end, false)

RegisterCommand('chathistory', function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, Config.Permissions.adminCommand) then
        local targetId = tonumber(args[1])
        if targetId then
            getPlayerHistory(targetId, Config.Database.AdminPanel.HistoryLimit, function(history)
                TriggerClientEvent('cdtChat:showHistory', source, {
                    playerId = targetId,
                    playerName = GetPlayerName(targetId),
                    messages = history
                })
            end)
        end
    end
end, false)

RegisterServerEvent('cdtChat:mutePlayerCommand')
AddEventHandler('cdtChat:mutePlayerCommand', function(playerId, duration, reason)
    local source = source
    local lang = Config.Language.Default
    local msgs = Config.Messages[lang] or Config.Messages.fr
    
    if IsPlayerAceAllowed(source, Config.Permissions.adminCommand) then
        local adminName = GetPlayerName(source)
        mutePlayer(playerId, duration, reason, adminName)
        TriggerClientEvent('chat:addMessage', source, {
            args = {'ADMIN', string.format(msgs.MuteAdminMessage, GetPlayerName(playerId), duration)}
        })
        TriggerClientEvent('cdtChat:playerMuted', playerId, duration)
    end
end)

RegisterServerEvent('cdtChat:unmutePlayerCommand')
AddEventHandler('cdtChat:unmutePlayerCommand', function(playerId)
    local source = source
    local lang = Config.Language.Default
    local msgs = Config.Messages[lang] or Config.Messages.fr
    
    if IsPlayerAceAllowed(source, Config.Permissions.adminCommand) then
        unmutePlayer(playerId)
        TriggerClientEvent('chat:addMessage', source, {
            args = {'ADMIN', string.format(msgs.UnmuteAdminMessage, GetPlayerName(playerId))}
        })
        TriggerClientEvent('cdtChat:playerUnmuted', playerId)
    end
end)

local function sendAdminPanelData(source, players)
    local histories = {}
    local muteStatuses = {}
    local completed = 0
    local totalPlayers = #players
    
    print('^3[Admin] Total players: ' .. totalPlayers .. '^7')
    
    local function checkAndSend()
        if completed == totalPlayers then
            print('^2[Admin] Sending admin panel data to ' .. source .. '^7')
            TriggerClientEvent('cdtChat:openAdminPanel', source, {
                players = players,
                histories = histories,
                muteStatuses = muteStatuses
            })
        end
    end
    
    if totalPlayers == 0 then
        checkAndSend()
    else
        for _, player in ipairs(players) do
            local identifier = GetPlayerIdentifiers(player.id)[1] or 'unknown'
            player.identifier = identifier
            
            print('^3[Admin] Getting history for identifier ' .. identifier .. '^7')
            getPlayerHistoryByIdentifier(identifier, Config.Database.AdminPanel.HistoryLimit, function(history)
                print('^3[Admin] Got history for identifier ' .. identifier .. ' (' .. (history and #history or 0) .. ' messages)^7')
                histories[identifier] = history or {}
                
                local muteResult = exports.oxmysql:query_async('SELECT * FROM player_mutes WHERE identifier = ? AND muted_until > ?', {identifier, os.time()})
                if muteResult and #muteResult > 0 then
                    muteStatuses[identifier] = {
                        isMuted = true,
                        mutedUntil = muteResult[1].muted_until,
                        mutedBy = muteResult[1].muted_by,
                        reason = muteResult[1].reason
                    }
                else
                    muteStatuses[identifier] = {
                        isMuted = false
                    }
                end
                
                completed = completed + 1
                checkAndSend()
            end)
        end
    end
end

RegisterNetEvent('cdtChat:openAdminPanelEvent')
AddEventHandler('cdtChat:openAdminPanelEvent', function()
    local source = source
    local lang = Config.Language.Default
    local msgs = Config.Messages[lang] or Config.Messages.fr
    
    print('^3[Admin] Command received from player ' .. source .. '^7')
    if IsPlayerAceAllowed(source, Config.Permissions.adminCommand) then
        local players = {}
        for _, pid in ipairs(GetPlayers()) do
            local playerId = tonumber(pid)
            table.insert(players, {
                id = playerId,
                name = GetPlayerName(playerId),
                identifier = GetPlayerIdentifiers(playerId)[1] or 'N/A'
            })
        end
        
        sendAdminPanelData(source, players)
    else
        print('^1[Admin] Access denied for ' .. source .. '^7')
        TriggerClientEvent('chat:addMessage', source, {
            args = {'SYSTEM', msgs.AdminPermissionDenied}
        })
    end
end)

RegisterNetEvent('cdtChat:refreshAdminPanelData')
AddEventHandler('cdtChat:refreshAdminPanelData', function()
    local source = source
    print('^3[Admin] Refresh request from player ' .. source .. '^7')
    if IsPlayerAceAllowed(source, Config.Permissions.adminCommand) then
        local players = {}
        for _, pid in ipairs(GetPlayers()) do
            local playerId = tonumber(pid)
            table.insert(players, {
                id = playerId,
                name = GetPlayerName(playerId),
                identifier = GetPlayerIdentifiers(playerId)[1] or 'N/A'
            })
        end
        
        sendAdminPanelData(source, players)
    else
        print('^1[Admin] Access denied for ' .. source .. '^7')
    end
end)

local function saveZoneSetting(identifier, zoneId, settings)
    if GetResourceState('oxmysql') ~= 'started' then return end
    
    local query = [[
        INSERT INTO chat_zone_settings (identifier, zone_id, color, opacity, top, `left`, width, height, show_auto)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
        color = VALUES(color),
        opacity = VALUES(opacity),
        top = VALUES(top),
        `left` = VALUES(`left`),
        width = VALUES(width),
        height = VALUES(height),
        show_auto = VALUES(show_auto),
        updated_at = NOW()
    ]]
    
    exports.oxmysql:query_async(query, {
        identifier,
        zoneId,
        settings.color,
        settings.opacity,
        settings.top,
        settings.left,
        settings.width,
        settings.height,
        settings.showAuto and 1 or 0
    }, function(result) end)
end

local function loadZoneSettings(identifier, zoneId, callback)
    if GetResourceState('oxmysql') ~= 'started' then
        callback(nil)
        return
    end
    
    local result = exports.oxmysql:query_async('SELECT * FROM chat_zone_settings WHERE identifier = ? AND zone_id = ?', {identifier, zoneId})
    
    if result and #result > 0 then
        callback({
            color = result[1].color,
            opacity = result[1].opacity,
            top = result[1].top,
            left = result[1].left,
            width = result[1].width,
            height = result[1].height,
            showAuto = result[1].show_auto == 1
        })
    else
        callback(nil)
    end
end

local function savePlayerLanguage(identifier, language)
    if GetResourceState('oxmysql') ~= 'started' then return end
    
    if not language or language == '' then
        language = Config.Language.Default
    end
    
    exports.oxmysql:query_async(
        'INSERT INTO player_settings (identifier, language) VALUES (?, ?) ON DUPLICATE KEY UPDATE language = ?, updated_at = NOW()',
        {identifier, language, language},
        function() end
    )
end

local function loadPlayerLanguage(identifier, callback)
    if GetResourceState('oxmysql') ~= 'started' then
        callback(Config.Language.Default)
        return
    end
    
    local result = exports.oxmysql:query_async('SELECT language FROM player_settings WHERE identifier = ?', {identifier})
    
    if result and #result > 0 and result[1].language then
        callback(result[1].language)
    else
        callback(Config.Language.Default)
    end
end

RegisterNetEvent('cdtChat:saveSettings')
AddEventHandler('cdtChat:saveSettings', function(data)
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1] or 'unknown'
    if data.type and data.color then
        saveZoneSetting(identifier, data.type, data)
        print('^2[Chat Settings] Saved settings for ' .. identifier .. ' - ' .. data.type .. '^7')
    end
end)

RegisterNetEvent('cdtChat:loadSettings')
AddEventHandler('cdtChat:loadSettings', function()
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1] or 'unknown'
    loadZoneSettings(identifier, 'messages-zone', function(settings)
        TriggerClientEvent('cdtChat:settingsLoaded', source, 'messages-zone', settings)
    end)
    loadZoneSettings(identifier, 'chat-container', function(settings)
        TriggerClientEvent('cdtChat:settingsLoaded', source, 'chat-container', settings)
    end)
    loadPlayerLanguage(identifier, function(language)
        TriggerClientEvent('cdtChat:languageLoaded', source, language)
    end)
end)

RegisterNetEvent('cdtChat:saveLanguage')
AddEventHandler('cdtChat:saveLanguage', function(language)
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1] or 'unknown'
    
    if not language or language == '' then
        language = Config.Language.Default
    end
    
    for _, validLang in ipairs(Config.Language.Available) do
        if validLang == language then
            savePlayerLanguage(identifier, language)
            break
        end
    end
end)

local function sendSystemMessageToAdmins(messageType, messageText, importance)
    if not Config.SystemMessages.Enabled then
        return
    end
    
    local typeConfig = Config.SystemMessages.Types[messageType]
    if not typeConfig then
        return
    end
    
    for _, playerId in ipairs(GetPlayers()) do
        if IsPlayerAceAllowed(playerId, Config.Permissions.adminCommand) then
            TriggerClientEvent('cdtChat:systemMessage', playerId, {
                type = messageType,
                text = messageText,
                importance = importance or 'info',
                timestamp = os.time()
            })
        end
    end
end

RegisterNetEvent('cdtChat:toggleSystemMessages')
AddEventHandler('cdtChat:toggleSystemMessages', function(enabled)
    local source = source
    if not IsPlayerAceAllowed(source, Config.Permissions.adminCommand) then
        return
    end
    
    TriggerClientEvent('cdtChat:updateSystemMessagesStatus', source, enabled)
end)

local ServerExports = {}

function ServerExports.sendSimpleAnnouncement(message, targets)
    if not message or message == '' then return end
    targets = targets or 'all'
    
    if targets == 'all' then
        for _, pid in ipairs(GetPlayers()) do
            TriggerClientEvent('cdtChat:sendAnnouncement', tonumber(pid), message)
        end
    elseif type(targets) == 'table' then
        for _, playerId in ipairs(targets) do
            TriggerClientEvent('cdtChat:sendAnnouncement', tonumber(playerId), message)
        end
    elseif type(targets) == 'number' then
        TriggerClientEvent('cdtChat:sendAnnouncement', targets, message)
    end
end

function ServerExports.sendAdvancedAnnouncement(data, targets)
    if not data or not data.message then return end
    targets = targets or 'all'
    
    local announcementData = {
        importance = data.importance or 'info',
        message = tostring(data.message),
        duration = tonumber(data.duration) or 5,
        formatting = {
            bold = data.formatting and data.formatting.bold == true or false,
            italic = data.formatting and data.formatting.italic == true or false,
            underline = data.formatting and data.formatting.underline == true or false,
            color = (data.formatting and data.formatting.color) or Config.Announcement.DefaultFormatting.color
        }
    }
    
    if targets == 'all' then
        for _, pid in ipairs(GetPlayers()) do
            TriggerClientEvent('cdtChat:showAdvancedAnnouncement', tonumber(pid), announcementData)
        end
    elseif type(targets) == 'table' then
        for _, playerId in ipairs(targets) do
            TriggerClientEvent('cdtChat:showAdvancedAnnouncement', tonumber(playerId), announcementData)
        end
    elseif type(targets) == 'number' then
        TriggerClientEvent('cdtChat:showAdvancedAnnouncement', targets, announcementData)
    end
end

function ServerExports.mutePlayer(playerId, duration, reason)
    if not playerId then return false end
    duration = duration or Config.Mute.DefaultDuration
    reason = reason or 'No reason provided'
    
    local adminName = 'SYSTEM'
    mutePlayer(playerId, duration, reason, adminName)
    TriggerClientEvent('cdtChat:playerMuted', playerId, duration)
    return true
end

function ServerExports.unmutePlayer(playerId)
    if not playerId then return false end
    unmutePlayer(playerId)
    TriggerClientEvent('cdtChat:playerUnmuted', playerId)
    return true
end

function ServerExports.getPlayerMuteStatus(playerId, callback)
    if not playerId or not callback then return end
    getPlayerMuteStatus(playerId, function(isMuted, timeRemaining)
        callback(isMuted, timeRemaining)
    end)
end

function ServerExports.getPlayerHistory(playerId, limit, callback)
    if not playerId or not callback then return end
    limit = limit or Config.Database.History.Limit
    getPlayerHistory(playerId, limit, callback)
end

function ServerExports.getPlayerHistoryByIdentifier(identifier, limit, callback)
    if not identifier or not callback then return end
    limit = limit or Config.Database.History.Limit
    getPlayerHistoryByIdentifier(identifier, limit, callback)
end

function ServerExports.checkBlockedWords(message)
    if not message then return false, nil end
    return containsBlockedWord(message)
end

function ServerExports.addMessageToHistory(playerId, playerName, message)
    if not playerId or not message then return false end
    addMessageToHistory(playerId, playerName or 'Unknown', message)
    return true
end

function ServerExports.registerChatCommandHandler(commandName, callback)
    if not commandName or not callback then return false end
    commandHandlers[commandName] = callback
    return true
end

function ServerExports.sendChatMessage(playerId, source, message)
    if not playerId or not source or not message then return false end
    TriggerClientEvent('chat:addMessage', playerId, {
        args = {source, message},
        multiline = false
    })
    return true
end

function ServerExports.broadcastChatMessage(source, message)
    if not source or not message then return false end
    for _, pid in ipairs(GetPlayers()) do
        TriggerClientEvent('chat:addMessage', tonumber(pid), {
            args = {source, message},
            multiline = false
        })
    end
    return true
end

function ServerExports.sendSystemMessage(messageType, messageText, importance)
    if not messageType or not messageText then return false end
    sendSystemMessageToAdmins(messageType, messageText, importance or 'info')
    return true
end

function ServerExports.getOnlinePlayers()
    local players = {}
    for _, pid in ipairs(GetPlayers()) do
        local playerId = tonumber(pid)
        table.insert(players, {
            id = playerId,
            name = GetPlayerName(playerId),
            identifier = GetPlayerIdentifiers(playerId)[1] or 'unknown'
        })
    end
    return players
end

function ServerExports.isPlayerMuted(playerId, callback)
    if not playerId then 
        if callback then callback(false, 0) end
        return 
    end
    getPlayerMuteStatus(playerId, function(isMuted, timeRemaining)
        if callback then
            callback(isMuted, timeRemaining)
        end
    end)
end

exports('sendSimpleAnnouncement', ServerExports.sendSimpleAnnouncement)
exports('sendAdvancedAnnouncement', ServerExports.sendAdvancedAnnouncement)
exports('mutePlayer', ServerExports.mutePlayer)
exports('unmutePlayer', ServerExports.unmutePlayer)
exports('getPlayerMuteStatus', ServerExports.getPlayerMuteStatus)
exports('getPlayerHistory', ServerExports.getPlayerHistory)
exports('getPlayerHistoryByIdentifier', ServerExports.getPlayerHistoryByIdentifier)
exports('checkBlockedWords', ServerExports.checkBlockedWords)
exports('addMessageToHistory', ServerExports.addMessageToHistory)
exports('registerChatCommandHandler', ServerExports.registerChatCommandHandler)
exports('sendChatMessage', ServerExports.sendChatMessage)
exports('broadcastChatMessage', ServerExports.broadcastChatMessage)
exports('sendSystemMessage', ServerExports.sendSystemMessage)
exports('getOnlinePlayers', ServerExports.getOnlinePlayers)
exports('isPlayerMuted', ServerExports.isPlayerMuted)
