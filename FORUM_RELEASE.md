# CDT Chat System - Free & Open Source

## 🎉 Introduction

**CDT Chat System** is a free, fully customizable chat resource for FiveM that replaces the default chat with a modern, feature-rich interface. Perfect for roleplay servers looking for an advanced communication system without breaking the bank!

---

## ✨ Features

### Core Functionality
- **Modern UI Interface** - Sleek, responsive chat window with customizable positioning and styling
- **Advanced Roleplay Commands**
  - `/me` - Display roleplay actions visible within a configurable range
  - `/do` - Show narrative descriptions to nearby players
  - `/annonce` - Server announcements with admin permissions
  
### Safety & Moderation
- **Intelligent Mute System** - Automatic and manual player muting with customizable durations
- **Blocked Words Filter** - Automatic muting for attempts to use blocked commands or keywords
- **ACE Permission Integration** - Full integration with FiveM's permission system

### Data Management
- **Chat History** - Complete message logging with oxmysql integration
- **Admin Panel** - Dedicated interface for administrators to manage chat and view history
- **Database Persistence** - All data safely stored in your database

### Customization & Localization
- **5 Languages Supported** - French, English, German, Spanish, Portuguese
- **Fully Configurable** - Customize everything from chat position to command ranges
- **Professional Styling** - Modern design with customizable colors and borders

---

## 🚀 Installation

### Requirements
- FiveM Server
- `oxmysql` resource (for database features)
- Basic server administration knowledge

### Step-by-Step Installation

1. **Download the Resource**
   ```
   https://github.com/Chris29380/chat
   ```

2. **Add to Your Server**
   - Extract the `chat` folder to your `resources` directory
   - Add `ensure chat` to your `server.cfg`

3. **Configure Database** (if using database features)
   - Ensure `oxmysql` is running
   - Set `Database.Enabled = true` in `config.lua`

4. **Set Permissions** (for admin commands)
   ```
   add_ace identifier.discord:YOUR_DISCORD_ID admin.announce allow
   add_ace identifier.discord:YOUR_DISCORD_ID chat.admin allow
   ```

5. **Start Your Server**
   ```
   /ensure cdt-chat
   ```

---

## 📋 Available Commands

| Command | Description | Permission Required |
|---------|-------------|-------------------|
| `/me [message]` | Display a roleplay action | None |
| `/do [message]` | Show a narrative | None |
| `/annonce [message]` | Send a server announcement | `admin.announce` |
| `/adminchat` | Open admin panel | `chat.admin` |
| `/mute [id] [duration]` | Mute a player | `chat.admin` |
| `/unmute [id]` | Unmute a player | `chat.admin` |
| `/chathistory [id]` | View player chat history | `chat.admin` |

---

## ⚙️ Configuration Highlights

### Quick Setup Examples

**Change chat position to bottom-right:**
```lua
Config.Chat.Position = { x = 'right', y = 'bottom' }
```

**Increase /me visibility range:**
```lua
Config.MeCommand.Range = 100.0  -- Default: 50.0
```

**Set English as default language:**
```lua
Config.Language.Default = 'en'
```

**Add custom blocked words:**
```lua
table.insert(Config.BlockedWords, 'forbiddenword')
```

For comprehensive configuration guide, see `CONFIG_GUIDE.md` in the repository.

---

## 🎮 Why Choose CDT Chat?

✅ **100% Free & Open Source** - No hidden costs, full transparency  
✅ **Professional Quality** - Production-ready code used on live servers  
✅ **Active Support** - Community-driven development  
✅ **Highly Customizable** - Adapt to your server's needs  
✅ **Multilingual** - Support for 5 languages out of the box  
✅ **Database Integration** - Complete message history and admin tools  
✅ **Easy Installation** - Simple setup process  
✅ **Well Documented** - Detailed guides and comments in code

---

## 📂 What's Included

```
chat/
├── client/                 # Client-side chat logic
├── server/                 # Server-side chat logic
├── html/                   # Modern UI interface
├── config.lua              # Easy configuration
├── fxmanifest.lua          # FiveM manifest
├── README.md               # Full documentation
└── LICENSE                 # Open source license
```

---

## 🔧 System Information

| Category | Details |
|----------|---------|
| **Code Accessibility** | Yes - Full source code available |
| **Subscription-based** | No - Completely free |
| **Lines of Code** | ~2000+ (optimized & well-commented) |
| **Requirements** | oxmysql, FiveM Framework |
| **Support** | Yes - GitHub Issues & Discord |

---

## 🎓 Learning & Customization

The code is intentionally written to be educational:
- **Well-commented** - Understand exactly what each part does
- **Modular Design** - Easy to modify and extend
- **Best Practices** - Learn proper FiveM development patterns
- **Open Source** - Full transparency and community contributions welcome

---

## 🐛 Bug Reports & Features

Found a bug or have a feature request?
- **GitHub Issues**: https://github.com/Chris29380/cdt-chat/issues
- **Discord**: ChrisToF#0851

---

## 📞 Support

### Getting Help
- Check the `README.md` for common issues
- Review `config.lua` comments for configuration help
- Open an issue on GitHub for bugs
- Contact via Discord for direct support

### Community
We welcome community contributions! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Share your customizations

---

## 📜 License & Credits

**Author**: CDT  
**Contact**: ChrisToF#0851  
**License**: Open Source (See repository for details)

This resource was built with passion for the FiveM roleplay community. Special thanks to everyone who provides feedback and helps improve this project!

---

## 🌟 Server Showcase

Using CDT Chat? Add your server to showcase what you've built!

---

**Ready to upgrade your server's chat system?**

👉 **Download Now**: https://github.com/Chris29380/chat

Thank you for choosing CDT Chat System! We hope it enhances your server's roleplay experience.

---

## Checklist (for forum submission)

- [x] Reviewed Releases rules
- [x] Included detailed description of the work
- [x] Included download link (GitHub repository)
- [x] Filled out required information

---

## Required Information

### Code

|                                         |                                |
|-------------------------------------|----------------------------|
| **Code is accessible**       | Yes                 |
| **Subscription-based**      | No                 |
| **Lines (approximately)**  | ~2000              |
| **Requirements**                | oxmysql, FiveM Server      |
| **Support**                           | Yes                 |

---

*Last Updated: 2025-11-12*  
*Version: 1.0.0*  
*Status: Active Development*
