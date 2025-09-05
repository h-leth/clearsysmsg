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

- Docker installed
- Telegram Bot Token from [@BotFather](https://t.me/BotFather)

```dockerfile
FROM rust:1.70 as builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
WORKDIR /app
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/telegram-delete-join-bot .
ENV TELOXIDE_TOKEN=""
CMD ["./telegram-delete-join-bot"]
```

```bash
docker build -t telegram-delete-join-bot .
docker run -e TELOXIDE_TOKEN="your_token" telegram-delete-join-bot
```

### Option 2: Run as a service

#### Download binary for github

```bash
wget https://github.com/h-leth/clearsysmsg/releases/download/v.0.1/source.tar.gz
```

#### Build from source

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/telegram-delete-join-bot.git
   cd telegram-delete-join-bot
   ```

2. **Set up environment**
   ```bash
   export TELOXIDE_TOKEN="your_bot_token_here"
   ```

3. **Build and run**
   ```bash
   cargo build --release
   cargo run
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

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
cargo test

# Run with output
cargo test -- --nocapture

# Run specific test
cargo test test_is_deletable_service_message

# Check test coverage
cargo tarpaulin --out Html
```

### Test Coverage

- ✅ Service message detection
- ✅ Command handling
- ✅ Message filtering logic
- ✅ Bot addition detection
- ✅ Inline keyboard generation
- ✅ Error handling scenarios

## 🔧 Configuration

### Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `TELOXIDE_TOKEN` | ✅ | Bot token from BotFather | - |
| `RUST_LOG` | ❌ | Logging level | `info` |

### Advanced Configuration

For production deployments, consider:

```bash
# Enable detailed logging
export RUST_LOG=debug

# Set custom log format
export RUST_LOG_STYLE=always
```

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Development Setup

1. **Fork and clone the repository**
2. **Install Rust toolchain**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
3. **Install development dependencies**:
   ```bash
   cargo install cargo-tarpaulin  # For test coverage
   cargo install cargo-audit      # For security audits
   ```

### Pull Request Process

1. **Create a feature branch**: `git checkout -b feature/amazing-feature`
2. **Make your changes** with tests
3. **Run the test suite**: `cargo test`
4. **Check formatting**: `cargo fmt -- --check`
5. **Run clippy**: `cargo clippy -- -D warnings`
6. **Submit pull request** with clear description

### Code Style

- Follow [Rust Style Guide](https://doc.rust-lang.org/1.0.0/style/)
- Write tests for new functionality
- Add documentation for public functions
- Use meaningful commit messages

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
