#!/bin/bash

# ClearSysMsg Telegram Bot - Binary Installation Script
# This script downloads the binary and sets up the clearsysmsg bot as a systemd service

set -e

# Configuration
GITHUB_REPO="h-leth/clearsysmsg"
INSTALL_DIR="/opt/clearsysmsg"
SERVICE_USER="clearsysmsg"
BINARY_NAME="clearsysmsg"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    print_error "Neither curl nor wget is installed. Please install one of them first."
    exit 1
fi

if ! command -v awk &> /dev/null; then
    print_error "awk not installed. Please install"
fi

if ! command -v systemctl &> /dev/null; then
    print_error "systemctl not found. This script requires systemd."
    exit 1
fi

print_success "Prerequisites check passed"

# Detect architecture
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        armv7l|armv6l)
            echo "armv7"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

ARCH=$(detect_arch)
print_status "Detected architecture: $ARCH"

# Get latest release info
print_status "Fetching latest release information..."
if command -v curl &> /dev/null; then
    LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
else
    LATEST_RELEASE=$(wget -qO- "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
fi

# Extract version and download URL
VERSION=$(echo "$LATEST_RELEASE" | awk -F '"' '/"tag_name":/ { print $4 }')
if [[ -z "$VERSION" ]]; then
    print_error "Could not determine latest version"
    exit 1
fi

print_status "Latest version: $VERSION"

# Construct download URL (adjust based on actual release naming convention)
DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION/${BINARY_NAME}-${VERSION}-linux-${ARCH}.tar.gz"

# Alternative URLs to try if the above doesn't work
ALT_DOWNLOAD_URLS=(
    "https://github.com/$GITHUB_REPO/releases/download/$VERSION/${BINARY_NAME}-${ARCH}-unknown-linux.tar.gz"
    "https://github.com/$GITHUB_REPO/releases/download/$VERSION/${BINARY_NAME}-${ARCH}-linux.tar.gz"
    "https://github.com/$GITHUB_REPO/releases/download/$VERSION/${BINARY_NAME}-${ARCH}.tar.gz"
    "https://github.com/$GITHUB_REPO/releases/download/$VERSION/${BINARY_NAME}.tar.gz"
)

# Create user and group for the service
print_status "Creating $SERVICE_USER user and group..."
if ! id "$SERVICE_USER" &>/dev/null; then
    useradd -r -s /bin/false -d "$INSTALL_DIR" -c "ClearSysMsg Bot Service" "$SERVICE_USER"
    print_success "Created $SERVICE_USER user"
else
    print_warning "User $SERVICE_USER already exists"
fi

# Create directory structure
print_status "Creating directory structure..."
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$INSTALL_DIR/logs"
chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"

# Download the binary
print_status "Downloading binary..."
BINARY_PATH="$INSTALL_DIR/bin/$BINARY_NAME"

download_binary() {
    local url="$1"
    print_status "Trying to download from: $url"
    
    if command -v curl &> /dev/null; then
        if curl -L -f "$url" -o "$BINARY_PATH"; then
            return 0
        fi
    else
        if wget -q "$url" -O "$BINARY_PATH"; then
            return 0
        fi
    fi
    return 1
}

# Try main download URL first, then alternatives
if ! download_binary "$DOWNLOAD_URL"; then
    print_warning "Primary download URL failed, trying alternatives..."
    downloaded=false
    
    for alt_url in "${ALT_DOWNLOAD_URLS[@]}"; do
        if download_binary "$alt_url"; then
            downloaded=true
            break
        fi
    done
    
    if [[ "$downloaded" != "true" ]]; then
        print_error "Failed to download binary from all attempted URLs"
        print_error "Please check the GitHub releases page: https://github.com/$GITHUB_REPO/releases"
        exit 1
    fi
fi

# Make binary executable
chmod +x "$BINARY_PATH"
chown "$SERVICE_USER:$SERVICE_USER" "$BINARY_PATH"
print_success "Binary downloaded and installed"

# Verify binary
if ! "$BINARY_PATH" --version 2>/dev/null && ! "$BINARY_PATH" --help 2>/dev/null; then
    print_warning "Could not verify binary (this might be normal if the binary doesn't support --version or --help)"
fi

# Create environment file
print_status "Creating environment file..."
cat > "$INSTALL_DIR/.env" << 'EOF'
# Telegram Bot Configuration
# Get your token from @BotFather on Telegram
TELOXIDE_TOKEN=your_bot_token_here

# Logging Configuration (optional)
# Available levels: error, warn, info, debug, trace
RUST_LOG=info
RUST_LOG_STYLE=always
EOF

# Set proper permissions for environment file
chown "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR/.env"
chmod 600 "$INSTALL_DIR/.env"

# Create systemd service file
print_status "Creating systemd service file..."
cat > /etc/systemd/system/clearsysmsg.service << EOF
[Unit]
Description=ClearSysMsg Telegram Bot - Auto-delete system messages
Documentation=https://github.com/$GITHUB_REPO
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$SERVICE_USER
Group=$SERVICE_USER
WorkingDirectory=$INSTALL_DIR

EnvironmentFile=$INSTALL_DIR/.env

ExecStart=$BINARY_PATH

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$INSTALL_DIR

ProtectKernelTunables=true
ProtectControlGroups=true
ProtectKernelModules=true
PrivateDevices=true
RestrictSUIDSGID=true
RestrictRealtime=true
LockPersonality=true
MemoryDenyWriteExecute=true

MemoryMax=64M
CPUQuota=10%

StandardOutput=journal
StandardError=journal
SyslogIdentifier=clearsysmsg

[Install]
WantedBy=multi-user.target
EOF

# Create update script
print_status "Creating update script..."
cat > "$INSTALL_DIR/update.sh" << 'EOF'
#!/bin/bash
# ClearSysMsg Bot Update Script

set -e

GITHUB_REPO="h-leth/clearsysmsg"
INSTALL_DIR="/opt/clearsysmsg"
BINARY_NAME="telegram-delete-join-bot"

# Detect architecture
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64) echo "x86_64" ;;
        aarch64|arm64) echo "aarch64" ;;
        armv7l|armv6l) echo "armv7" ;;
        *) echo "unknown" ;;
    esac
}

ARCH=$(detect_arch)
if [[ "$ARCH" == "unknown" ]]; then
    echo "Error: Unsupported architecture"
    exit 1
fi

echo "Checking for updates..."

# Get latest release
if command -v curl &> /dev/null; then
    LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
else
    LATEST_RELEASE=$(wget -qO- "https://api.github.com/repos/$GITHUB_REPO/releases/latest")
fi

VERSION=$(echo "$LATEST_RELEASE" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [[ -z "$VERSION" ]]; then
    echo "Error: Could not determine latest version"
    exit 1
fi

echo "Latest version: $VERSION"

# Stop service
echo "Stopping service..."
sudo systemctl stop clearsysmsg

# Download new binary
DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION/${BINARY_NAME}-${VERSION}-linux-${ARCH}"
BINARY_PATH="$INSTALL_DIR/bin/$BINARY_NAME"
BACKUP_PATH="$INSTALL_DIR/bin/${BINARY_NAME}.backup"

# Backup current binary
if [[ -f "$BINARY_PATH" ]]; then
    cp "$BINARY_PATH" "$BACKUP_PATH"
fi

echo "Downloading new binary..."
if command -v curl &> /dev/null; then
    curl -L -f "$DOWNLOAD_URL" -o "$BINARY_PATH" || {
        echo "Error: Download failed"
        if [[ -f "$BACKUP_PATH" ]]; then
            mv "$BACKUP_PATH" "$BINARY_PATH"
        fi
        exit 1
    }
else
    wget -q "$DOWNLOAD_URL" -O "$BINARY_PATH" || {
        echo "Error: Download failed"
        if [[ -f "$BACKUP_PATH" ]]; then
            mv "$BACKUP_PATH" "$BINARY_PATH"
        fi
        exit 1
    }
fi

chmod +x "$BINARY_PATH"
chown clearsysmsg:clearsysmsg "$BINARY_PATH"

# Start service
echo "Starting service..."
sudo systemctl start clearsysmsg

echo "Update completed successfully!"
EOF

chmod +x "$INSTALL_DIR/update.sh"
chown "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR/update.sh"

# Reload systemd and enable service
print_status "Configuring systemd service..."
systemctl daemon-reload
systemctl enable clearsysmsg.service

print_success "ClearSysMsg service installation completed!"
print_status "Installation summary:"
echo "- Binary location: $BINARY_PATH"
echo "- Configuration: $INSTALL_DIR/.env"
echo "- Service user: $SERVICE_USER"
echo "- Update script: $INSTALL_DIR/update.sh"
echo ""
print_status "Next steps:"
echo "1. Edit $INSTALL_DIR/.env and add your bot token from @BotFather"
echo "2. Start the service: sudo systemctl start clearsysmsg"
echo "3. Check status: sudo systemctl status clearsysmsg"
echo "4. View logs: sudo journalctl -u clearsysmsg -f"
echo ""
print_warning "Remember to:"
echo "- Get your bot token from @BotFather on Telegram"
echo "- Add the bot to your groups as admin with 'Delete Messages' permission"
echo ""
print_status "Service commands:"
echo "- Start:   sudo systemctl start clearsysmsg"
echo "- Stop:    sudo systemctl stop clearsysmsg"
echo "- Restart: sudo systemctl restart clearsysmsg"
echo "- Status:  sudo systemctl status clearsysmsg"
echo "- Logs:    sudo journalctl -u clearsysmsg -f"
echo "- Update:  sudo $INSTALL_DIR/update.sh"
