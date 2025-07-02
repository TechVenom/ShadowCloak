#!/bin/bash

#==============================================================================
# ShadowCloak Configuration Module
# Contains all global variables and configuration settings
#==============================================================================

# Color codes for terminal output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export YELLOW2='\033[1;93m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# Global variables
export SCRIPT_NAME="ShadowCloak"
export VERSION="1.0"
export LOG_FILE="/var/log/shadowcloak.log"
export CONFIG_DIR="/etc/shadowcloak"
export BACKUP_DIR="$CONFIG_DIR/backup"
export TOR_PORT="9050"
export TOR_TRANS_PORT="9040"
export TOR_DNS_PORT="5353"
export SILENT_MODE=false
export SECURE_LOG=false
export INTERFACE=""
export ORIGINAL_MAC_FILE="$BACKUP_DIR/original_mac"
export ORIGINAL_HOSTNAME_FILE="$BACKUP_DIR/original_hostname"
export ORIGINAL_DNS_FILE="$BACKUP_DIR/original_dns"
export ORIGINAL_TIMEZONE_FILE="$BACKUP_DIR/original_timezone"

# Global variable for selected features
export SELECTED_FEATURES=()

# Secure DNS servers
export DNS_SERVERS=(
    "1.1.1.1"      # Cloudflare
    "1.0.0.1"      # Cloudflare
    "8.8.8.8"      # Google
    "8.8.4.4"      # Google
    "9.9.9.9"      # Quad9
    "149.112.112.112" # Quad9
)

# Random timezone list
export TIMEZONES=(
    "America/New_York"
    "America/Los_Angeles"
    "America/Chicago"
    "America/Denver"
    "Europe/London"
    "Europe/Paris"
    "Europe/Berlin"
    "Europe/Rome"
    "Asia/Tokyo"
    "Asia/Shanghai"
    "Asia/Mumbai"
    "Asia/Dubai"
    "Australia/Sydney"
    "Australia/Melbourne"
    "Pacific/Auckland"
    "America/Toronto"
    "America/Vancouver"
    "Europe/Amsterdam"
    "Europe/Stockholm"
    "Europe/Zurich"
)

# Browser paths for hardening
export FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox"
export BRAVE_CONFIG_DIR="$HOME/.config/BraveSoftware/Brave-Browser"
export CHROME_CONFIG_DIR="$HOME/.config/google-chrome"

# System directories
export SYSTEM_LOG_DIRS=(
    "/var/log"
    "/tmp"
    "/var/tmp"
    "$HOME/.bash_history"
    "$HOME/.zsh_history"
    "$HOME/.cache"
)

# Memory clearing targets
export MEMORY_TARGETS=(
    "drop_caches"
    "swap"
    "buffers"
    "dentries"
    "inodes"
)

# Network interfaces to check
export NETWORK_INTERFACES=(
    "wlan0"
    "eth0"
    "enp0s3"
    "wlp2s0"
    "ens33"
)

# Dependencies required for ShadowCloak
export REQUIRED_DEPS=(
    "tor"
    "macchanger"
    "curl"
    "timedatectl"
)

# Optional dependencies
export OPTIONAL_DEPS=(
    "firefox"
    "brave-browser"
    "google-chrome"
    "whiptail"
    "dialog"
)

# Feature names for display
export FEATURE_NAMES=(
    "Tor Routing"
    "MAC Randomization"
    "DNS Protection"
    "Hostname Camouflage"
    "Timezone Randomization"
    "Log Wiping"
    "Browser Hardening"
    "Memory Clearing"
    "Protocol Hardening"
)

# Configuration validation
validate_config() {
    # Ensure required directories exist
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
        chmod 700 "$CONFIG_DIR"
    fi
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        chmod 700 "$BACKUP_DIR"
    fi
    
    # Validate log file permissions
    if [[ -f "$LOG_FILE" ]]; then
        chmod 600 "$LOG_FILE"
    fi
    
    return 0
}

# Initialize configuration
init_config() {
    validate_config
    
    # Set default interface if not specified
    if [[ -z "$INTERFACE" ]]; then
        for iface in "${NETWORK_INTERFACES[@]}"; do
            if ip link show "$iface" &>/dev/null && [[ $(cat "/sys/class/net/$iface/operstate" 2>/dev/null) == "up" ]]; then
                INTERFACE="$iface"
                break
            fi
        done
    fi
    
    return 0
}

# Export all functions
export -f validate_config
export -f init_config
