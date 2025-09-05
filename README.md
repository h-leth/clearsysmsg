# **WORK IN PROGRESS**


# Telegram Clear system messages Bot

[![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://telegram.org/)
[![License: GPLv3](https://img.shields.io/badge/license-%20%20GNU%20GPLv3%20-yellow?style=plastic)](https://opensource.org/license/gpl-3-0)

A lightweight Telegram bot built with Rust that automatically deletes join/leave messages and other service notifications to keep your group chats clean and organized.

## ✨ Features

- 🧹 **Auto-Clean Service Messages**: Automatically removes join/leave notifications
- 🔒 **Privacy Focused**: No data collection or storage
- 🎯 **Zero Configuration**: Works out of the box once added to group
- 🚀 **Easy Setup**: One-click group addition with inline buttons

### Service Messages Removed

- ✅ User joined group
- ✅ User left group
- ✅ Group creation
- ✅ Supergroup creation
- ✅ Channel creation
- ✅ Message pinned

## 🚀 Quick Start

### Option 1: Docker Deployment

#### Prerequisites

- Docker installed on your system
- Telegram Bot Token from [@BotFather](https://t.me/BotFather)

### Use Docker Compose

1. Download docker-compose.yml and .env:
    ```bash
    wget https://github.com/h-leth/clearsysmsg/blob/master/Dockerfile
    wget https://github.com/h-leth/clearsysmsg/blob/master/.env
    ```

2. Confgure environment variables:
    ```bash
    # Replace 'your_bot_token_here' with your token from BotFather 
    nano .env
    ```

3. Start the bot:
    ```bash
    docker compose up -d
    ```

### Option 2: Run as a service

1. Create a service user
    ```bash
    sudo useradd -r -s /bin/false -d /opt/clearsysmsg clearsysmsg
    ```

2. Create directory structure:
    ```bash
    sudo mkdir -p /opt/clearsysmsg/bin
    sudo mkdir -p /opt/clearsysmsg/logs
    sudo chown -R clearsysmsg:clearsysmsg /opt/clearsysmsg
    ```


#### Download binary for github

```bash
# Get the latest tag and system architecture
TAG=$(curl -s https://api.github.com/repos/h-leth/h-leth/releases/latest | awk -F '"' '/"tag_name":/ { print $4 }')
ARCH=$(uname -m)

# Download 
sudo wget https://github.com/h-leth/clearsysmsg/releases/download/$TAG/clearsysmsg-$ARCH*.tar.xz \
-O /opt/clearsysmsg/bin/clearsysmsg

# Make executeable and set permissions
sudo chmod +x /opt/clearsysmsg/bin/clearsysmsg
sudo chown clearsysmsg:clearsysmsg /opt/clearsysmsg/bin/clearsysmsg
```


#### Build from source

1. **Clone the repository**
   ```bash
   git clone https://github.com/h-leth/clearsysmsg.git
   cd clearsysmsg
   ```

2. **Build**
   ```bash
   cargo build --release
   ```


## 📱 Bot Commands

| Command | Description |
|---------|-------------|
| `/start` | Show welcome message with setup instructions |
| `/status` | Display comprehensive help and setup guide |

## 🔧 Setup Instructions

### 1. Create Your Bot

1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Send `/newbot` and follow the instructions
3. Save your bot token securely

### 2. Configure Bot Settings

In BotFather, set these optional configurations:
- **Description**: "Automatically deletes join/leave messages to keep your group chat clean"
- **About**: "Clean Chat Bot - Removes service messages automatically"
- **Commands**: 
  ```
  start - Show welcome message
  status - Display status information  
  ```

### 3. Deploy and Add to Groups

1. Deploy your bot using one of the methods above
2. Add bot to your Telegram group
3. Promote to admin with "Delete Messages" permission
4. The bot will start working immediately

## 🛡️ Permissions Required

The bot needs these admin permissions to function:

- ✅ **Delete Messages** - Core functionality to remove service messages
- ❌ **All other permissions can be disabled**

## 🔧 Configuration

### Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `TELOXIDE_TOKEN` | ✅ | Bot token from BotFather | - |
| `DEVELOPER_CHAT_ID` | ❌ | Hoster's Telegram chat id | - |
| `RUST_LOG` | ❌ | Logging level | `info` |

### Advanced Configuration

For production deployments, consider:

```bash
# Enable detailed logging
export RUST_LOG=debug

# Set custom log format
export RUST_LOG_STYLE=always
```

## 🐛 Issues and Support

### Common Issues

<details>
<summary><strong>Bot not deleting messages</strong></summary>

**Cause**: Missing admin permissions

**Solution**:
1. Check bot is admin in group
2. Verify "Delete Messages" permission is enabled
3. Ensure bot was added after group creation
</details>

<details>
<summary><strong>"Failed to delete message" errors</strong></summary>

**Cause**: Permission issues or message too old

**Solution**:
1. Bot must be admin when service message is sent
2. Telegram has time limits on message deletion
3. Check bot token is valid and not revoked
</details>

<details>
<summary><strong>Bot not responding to commands</strong></summary>

**Cause**: Bot not running or token issues

**Solution**:
1. Verify bot process is running: `ps aux | grep telegram-bot`
2. Check logs for errors: `journalctl -u telegram-bot`
3. Validate bot token with BotFather
</details>

### Getting Help

- 📋 **Issues**: [Create an issue](https://github.com/h-leth/clearsysmsg/issues)

## 📄 License

This project is licensed under the GNU General Public Lisence v3.0 License - see the [LICENSE](LICENSE) file for details.

```
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

Copyright (C) 2024 Henning Kind Leth

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.```

---

<div align="center">

**[⭐ Star this repo](https://github.com/yourusername/telegram-delete-join-bot)** • **[🐛 Report Bug](https://github.com/yourusername/telegram-delete-join-bot/issues)** • **[✨ Request Feature](https://github.com/yourusername/telegram-delete-join-bot/issues)**

</div>
