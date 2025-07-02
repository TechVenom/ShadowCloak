#!/bin/bash

#==============================================================================
# ShadowCloak Installation Script
# Sets up the modular ShadowCloak system
#==============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}[INSTALLER]${NC} $message"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status "$YELLOW" "This installer should be run as root for system-wide installation."
        echo -n "Continue anyway? (y/N): "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Install dependencies
install_dependencies() {
    print_status "$BLUE" "Installing dependencies..."
    
    # Update package list
    apt update
    
    # Install required packages
    local packages=(
        "tor"
        "macchanger"
        "curl"
        "systemd"
        "jq"
        "net-tools"
        "dnsutils"
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            print_status "$YELLOW" "Installing $package..."
            apt install -y "$package"
        else
            print_status "$GREEN" "$package is already installed"
        fi
    done
    
    print_status "$GREEN" "Dependencies installed successfully"
}

# Setup directory structure
setup_directories() {
    print_status "$BLUE" "Setting up directory structure..."
    
    local install_dir="/opt/shadowcloak"
    local bin_dir="/usr/local/bin"
    
    # Create installation directory
    mkdir -p "$install_dir"
    mkdir -p "$install_dir/modules"
    
    # Copy files
    if [[ -f "shadowcloak_modular.sh" ]]; then
        cp "shadowcloak_modular.sh" "$install_dir/shadowcloak.sh"
        chmod +x "$install_dir/shadowcloak.sh"
        print_status "$GREEN" "Main script installed"
    else
        print_status "$RED" "Main script not found!"
        return 1
    fi
    
    # Copy modules
    if [[ -d "modules" ]]; then
        cp -r modules/* "$install_dir/modules/"
        chmod +x "$install_dir/modules"/*.sh
        print_status "$GREEN" "Modules installed"
    else
        print_status "$RED" "Modules directory not found!"
        return 1
    fi
    
    # Create symlink in PATH
    ln -sf "$install_dir/shadowcloak.sh" "$bin_dir/shadowcloak"
    
    # Set permissions
    chown -R root:root "$install_dir"
    chmod 755 "$install_dir"
    chmod 755 "$install_dir/modules"
    
    print_status "$GREEN" "Directory structure created"
}

# Create desktop entry
create_desktop_entry() {
    print_status "$BLUE" "Creating desktop entry..."
    
    cat > /usr/share/applications/shadowcloak.desktop << EOF
[Desktop Entry]
Name=ShadowCloak
Comment=Advanced Privacy & Anonymity Suite
Exec=gnome-terminal -- shadowcloak start
Icon=security-high
Type=Application
Categories=System;Security;Network;
Terminal=true
StartupNotify=true
EOF
    
    print_status "$GREEN" "Desktop entry created"
}

# Setup systemd service (optional)
setup_service() {
    print_status "$BLUE" "Setting up systemd service..."
    
    cat > /etc/systemd/system/shadowcloak.service << EOF
[Unit]
Description=ShadowCloak Privacy Suite
After=network.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/opt/shadowcloak/shadowcloak.sh start --silent
ExecStop=/opt/shadowcloak/shadowcloak.sh stop
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    
    print_status "$GREEN" "Systemd service created"
    print_status "$YELLOW" "To enable auto-start: systemctl enable shadowcloak"
}

# Create configuration file
create_config() {
    print_status "$BLUE" "Creating configuration file..."
    
    mkdir -p /etc/shadowcloak
    
    cat > /etc/shadowcloak/shadowcloak.conf << EOF
# ShadowCloak Configuration File
# Modify these settings to customize behavior

# Default network interface (leave empty for auto-detection)
INTERFACE=""

# Enable silent mode by default (true/false)
SILENT_MODE=false

# Enable secure logging (true/false)
SECURE_LOG=false

# Default features to enable in silent mode (0-8)
DEFAULT_FEATURES="0,1,2,3,4,5,6,7,8"

# Tor configuration
TOR_PORT=9050
TOR_TRANS_PORT=9040
TOR_DNS_PORT=5353

# Backup retention (days)
BACKUP_RETENTION=7

# Log file location
LOG_FILE="/var/log/shadowcloak.log"
EOF
    
    chmod 600 /etc/shadowcloak/shadowcloak.conf
    
    print_status "$GREEN" "Configuration file created"
}

# Show installation summary
show_summary() {
    print_status "$CYAN" "Installation completed successfully!"
    echo ""
    echo -e "${WHITE}Installation Summary:${NC}"
    echo -e "  ${GREEN}✓${NC} ShadowCloak installed to: /opt/shadowcloak"
    echo -e "  ${GREEN}✓${NC} Command available as: shadowcloak"
    echo -e "  ${GREEN}✓${NC} Modules installed: 7 modules"
    echo -e "  ${GREEN}✓${NC} Dependencies installed"
    echo -e "  ${GREEN}✓${NC} Desktop entry created"
    echo -e "  ${GREEN}✓${NC} Systemd service created"
    echo -e "  ${GREEN}✓${NC} Configuration file created"
    echo ""
    echo -e "${WHITE}Usage Examples:${NC}"
    echo -e "  ${CYAN}shadowcloak start${NC}          # Interactive mode"
    echo -e "  ${CYAN}shadowcloak start --silent${NC} # Silent mode (all features)"
    echo -e "  ${CYAN}shadowcloak status${NC}         # Show current status"
    echo -e "  ${CYAN}shadowcloak stop${NC}           # Stop and restore settings"
    echo -e "  ${CYAN}shadowcloak help${NC}           # Show help"
    echo ""
    echo -e "${WHITE}Optional:${NC}"
    echo -e "  ${YELLOW}systemctl enable shadowcloak${NC}  # Enable auto-start"
    echo -e "  ${YELLOW}systemctl start shadowcloak${NC}   # Start service now"
    echo ""
}

# Main installation function
main() {
    echo -e "${CYAN}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                   🕶️  SHADOWCLOAK INSTALLER 🕶️                ║"
    echo "  ║              Advanced Privacy & Anonymity Suite              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    print_status "$BLUE" "Starting ShadowCloak installation..."
    
    # Check if we're in the right directory
    if [[ ! -f "shadowcloak_modular.sh" || ! -d "modules" ]]; then
        print_status "$RED" "Installation files not found!"
        print_status "$RED" "Please run this installer from the ShadowCloak directory"
        exit 1
    fi
    
    # Run installation steps
    check_root
    install_dependencies
    setup_directories
    create_desktop_entry
    setup_service
    create_config
    
    show_summary
}

# Run main function
main "$@"
