# Exports Client

## Description

Les exports client permettent aux autres ressources d'interagir avec le système de chat du côté joueur.

**Total: 12 fonctions d'export**

---

## 1. openChat()

**Description:** Ouvre le chat

```lua
exports.chat:openChat()
```

**Paramètres:** Aucun  
**Retour:** void

**Exemple:**
```lua
RegisterCommand('openchat', function()
    exports.chat:openChat()
end, false)
```

---

## 2. closeChat()

**Description:** Ferme le chat

```lua
exports.chat:closeChat()
```

**Paramètres:** Aucun  
**Retour:** void

**Exemple:**
```lua
exports.chat:closeChat()
```

---

## 3. isChatActive()

**Description:** Vérifie si le chat est actuellement ouvert

```lua
local isActive = exports.chat:isChatActive()
```

**Paramètres:** Aucun  
**Retour:** `boolean` - true si le chat est ouvert

**Exemple:**
```lua
if exports.chat:isChatActive() then
    print("Le chat est ouvert")
else
    print("Le chat est fermé")
end
```

---

## 4. isMuted()

**Description:** Vérifie si le joueur est actuellement mute

```lua
local muted = exports.chat:isMuted()
```

**Paramètres:** Aucun  
**Retour:** `boolean` - true si le joueur est mute

**Exemple:**
```lua
if exports.chat:isMuted() then
    exports.chat:addMessage('SYSTEM', 'Vous êtes mute')
else
    exports.chat:addMessage('SYSTEM', 'Vous pouvez parler')
end
```

---

## 5. getMuteTimeRemaining()

**Description:** Récupère le temps de mute restant en secondes

```lua
local timeRemaining = exports.chat:getMuteTimeRemaining()
```

**Paramètres:** Aucun  
**Retour:** `number` - Temps restant en secondes (0 si pas mute)

**Exemple:**
```lua
local remaining = exports.chat:getMuteTimeRemaining()
if remaining > 0 then
    print("Mute restant: " .. remaining .. "s")
end
```

---

## 6. hasAnnouncePermission()

**Description:** Vérifie si le joueur a la permission d'envoyer des annonces

```lua
local hasPermission = exports.chat:hasAnnouncePermission()
```

**Paramètres:** Aucun  
**Retour:** `boolean` - true si autorisé

**Exemple:**
```lua
if exports.chat:hasAnnouncePermission() then
    exports.chat:sendAnnouncement("Annonce importante!")
else
    exports.chat:addMessage('ERROR', 'Vous n\'avez pas la permission')
end
```

---

## 7. isAdmin()

**Description:** Vérifie si le joueur est administrateur

```lua
local admin = exports.chat:isAdmin()
```

**Paramètres:** Aucun  
**Retour:** `boolean` - true si admin

**Exemple:**
```lua
if exports.chat:isAdmin() then
    print("Joueur est administrateur")
end
```

---

## 8. sendMe(message)

**Description:** Envoie une action /me

```lua
exports.chat:sendMe(message)
```

**Paramètres:**
- `message` (string) - Texte de l'action

**Retour:** void

**Exemple:**
```lua
exports.chat:sendMe("se gratte la tête")
exports.chat:sendMe("effectue une danse")
```

---

## 9. sendDo(message)

**Description:** Envoie une description /do

```lua
exports.chat:sendDo(message)
```

**Paramètres:**
- `message` (string) - Texte de la description

**Retour:** void

**Exemple:**
```lua
exports.chat:sendDo("La porte s'ouvre lentement")
exports.chat:sendDo("Une explosion retentit au loin")
```

---

## 10. sendAnnouncement(message)

**Description:** Envoie une annonce à tous les joueurs (si permission)

```lua
exports.chat:sendAnnouncement(message)
```

**Paramètres:**
- `message` (string) - Texte de l'annonce

**Retour:** void

**Exemple:**
```lua
exports.chat:sendAnnouncement("Redémarrage du serveur dans 5 minutes!")
```

---

## 11. addMessage(source, message)

**Description:** Ajoute un message au chat local du joueur

```lua
exports.chat:addMessage(source, message)
```

**Paramètres:**
- `source` (string) - Nom de la source (ex: 'SYSTEM', 'ADMIN')
- `message` (string) - Texte du message

**Retour:** void

**Exemple:**
```lua
exports.chat:addMessage('SYSTEM', 'Bienvenue sur le serveur!')
exports.chat:addMessage('ADMIN', 'Tu es maintenant administrateur')
exports.chat:addMessage('INFO', 'Commande exécutée avec succès')
```

---

## 12. getPlayerMuteStatus(callback)

**Description:** Récupère l'état du mute avec un callback

```lua
exports.chat:getPlayerMuteStatus(callback)
```

**Paramètres:**
- `callback` (function) - Fonction appelée avec (isMuted, timeRemaining)

**Retour:** void

**Exemple:**
```lua
exports.chat:getPlayerMuteStatus(function(isMuted, timeRemaining)
    if isMuted then
        print("Mute pour " .. timeRemaining .. " secondes")
    else
        print("Pas mute")
    end
end)
```

---

## Utilisation dans d'autres ressources

```lua
-- Vérifier l'état avant d'agir
if exports.chat:isMuted() then
    return
end

-- Envoyer une action
exports.chat:sendMe("effectue une action")

-- Ajouter un message
exports.chat:addMessage('MON_SCRIPT', 'Message personnalisé')

-- Vérifier les permissions
if exports.chat:hasAnnouncePermission() then
    exports.chat:sendAnnouncement('Message important')
end
```
