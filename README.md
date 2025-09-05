# Telegram Clear system messages Bot

[![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://telegram.org/)
[![License: GPLv3](https://img.shields.io/badge/license-%20%20GNU%20GPLv3%20-yellow?style=plastic)](https://opensource.org/license/gpl-3-0)

A lightweight Telegram bot built with Rust that automatically deletes join/leave messages and other service notifications to keep your group chats clean and organized.
Motivation for this project is to make an easy to deploy bot that "everbody" can host for their own channels. And not be depentable of a random bot that you're not certain about how handle your data.

## ✨ Features

-  **Auto-Clean Service Messages**: Automatically removes join/leave notifications
-  **Privacy Focused**: No data collection or storage
-  **Zero Configuration**: Works out of the box once added to group
-  **Easy Setup**: One-click group addition with inline buttons

### Service Messages Removed

-  User joined group
-  User left group
-  Group creation
-  Supergroup creation
-  Channel creation
-  Message pinned

## Setup Instructions

#### Prerequisites

- Docker installed on your system
- Telegram Bot Token from [@BotFather](https://t.me/BotFather)

### 1. Create Your Bot

1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Send `/newbot` and follow the instructions
3. Save your bot token securely

### 2. Configure Bot Settings

In BotFather, set these optional configurations:
- **Description**: "Automatically deletes join/leave messages to keep your group chat clean"
- **About**: "ClearSysMsg bot- Removes service messages automatically"
- **Commands**: 
```
start - Show getting started message
status - Display bot status information  
```

### 3 .Docker Deployment

#### Alt 1. Docker Compose (Recommended)

1. Download docker-compose.yml and .env:
    ```bash
    mkdir clearsysmsg && cd clearsysmsg
    curl -O https://raw.githubusercontent.com/h-leth/clearsysmsg/refs/heads/master/docker-compose.yaml
    curl -O https://raw.githubusercontent.com/h-leth/clearsysmsg/refs/heads/master/.env
    ```

2. Confgure environment variables:
    ```bash
    # Replace "your_bot_token_here" with your token from BotFather 
    # Provided a easy oneliner to update just token or use your favorite text editor if you rather perfer
    sed -i -e 's/your_bot_token_here/"token from BotFather"/g' .env
    ```

3. Start the bot:
    ```bash
    docker compose up -d
    ```
#### Alt 2. Docker run
```bash 
docker run --restart unless-stopped \
-e TELOXIDE_TOKEN="token from BotFather" \
-e RUST_LOG="info" \
--name telegram-clearsysmsg-bot \
hleth/clearsysmsg:latest
```

### 4. Deploy and Add to Groups

1. Deploy your bot using one of the methods above
2. Add bot to your Telegram group
3. Promote to admin with "Delete Messages" permission
4. The bot will start working immediately

## Bot Commands

    | Command | Description |
    |---------|-------------|
    | `/start` | Show getting started message with setup instructions |
    | `/status` | Display bot status information|

## Permissions Required

    The bot needs these admin permissions to function:

    - ✅ **Delete Messages** - Core functionality to remove service messages
    - ❌ **All other permissions can be disabled**

## Configuration

### Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `TELOXIDE_TOKEN` | ✅ | Bot token from BotFather | - |
| `HOSTER_CHAT_ID` | ❌ | Hoster's Telegram chat id | - |
| `RUST_LOG` | ❌ | Logging level | `info` |

### Advanced Configuration

For production deployments, consider:

```bash
# Enable detailed logging
export RUST_LOG=debug

# Set custom log format
export RUST_LOG_STYLE=always
```

#### Option: Build from source

##### Prerequisites
- Rust toolchain installed on your system

1. **Clone the repository**
```bash
git clone https://github.com/h-leth/clearsysmsg.git
cd clearsysmsg
```

2. **Build**
```bash
cargo build --release
```

3. **Copy binary**
```bash
sudo cp ./target/release/clearsysmsg /opt/clearsysmsg/bin
```

## Issues and Support

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
1. Verify bot process is running: `docker container ps`
2. Check logs for errors: `docker logs telegram-clearsysmsg-bot`
3. Validate bot token with BotFather

</details>

### Getting Help

- **Issues**: [Create an issue](https://github.com/h-leth/clearsysmsg/issues)

## License

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
