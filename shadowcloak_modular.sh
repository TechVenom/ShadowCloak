#!/bin/bash

#==============================================================================
# ShadowCloak - Advanced Privacy & Anonymity Suite
# Modular version with separated components
# Author: TechByte Security
# Version: 1.0
# Compatible: Debian-based systems (Kali, Parrot, Ubuntu)
#==============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# Check if modules directory exists
if [[ ! -d "$MODULES_DIR" ]]; then
    echo "Error: Modules directory not found at $MODULES_DIR"
    echo "Please ensure all module files are in the modules/ directory"
    exit 1
fi

# Import all modules
echo "Loading ShadowCloak modules..."

# Load configuration first
if [[ -f "$MODULES_DIR/config.sh" ]]; then
    source "$MODULES_DIR/config.sh"
    echo "✓ Configuration module loaded"
else
    echo "✗ Configuration module not found"
    exit 1
fi

# Load utilities
if [[ -f "$MODULES_DIR/utils.sh" ]]; then
    source "$MODULES_DIR/utils.sh"
    echo "✓ Utilities module loaded"
else
    echo "✗ Utilities module not found"
    exit 1
fi

# Load network functions
if [[ -f "$MODULES_DIR/network.sh" ]]; then
    source "$MODULES_DIR/network.sh"
    echo "✓ Network module loaded"
else
    echo "✗ Network module not found"
    exit 1
fi

# Load anonymity functions
if [[ -f "$MODULES_DIR/anonymity.sh" ]]; then
    source "$MODULES_DIR/anonymity.sh"
    echo "✓ Anonymity module loaded"
else
    echo "✗ Anonymity module not found"
    exit 1
fi

# Load system functions
if [[ -f "$MODULES_DIR/system.sh" ]]; then
    source "$MODULES_DIR/system.sh"
    echo "✓ System module loaded"
else
    echo "✗ System module not found"
    exit 1
fi

# Load browser functions
if [[ -f "$MODULES_DIR/browser.sh" ]]; then
    source "$MODULES_DIR/browser.sh"
    echo "✓ Browser module loaded"
else
    echo "✗ Browser module not found"
    exit 1
fi

# Load interface functions
if [[ -f "$MODULES_DIR/interface.sh" ]]; then
    source "$MODULES_DIR/interface.sh"
    echo "✓ Interface module loaded"
else
    echo "✗ Interface module not found"
    exit 1
fi

echo "All modules loaded successfully!"
echo ""

# Initialize configuration
init_config

# Stop and restore function
stop_shadowcloak() {
    print_status "$CYAN" "Stopping ShadowCloak and restoring settings..."

    # Stop Tor
    systemctl stop tor

    # Note: No iptables restoration needed with basic Tor setup

    # Restore MAC address
    restore_mac

    # Restore hostname
    restore_hostname

    # Restore timezone
    restore_timezone

    # Restore DNS
    if [[ -f "$BACKUP_DIR/resolv.conf_"* ]]; then
        local latest_backup=$(ls -t "$BACKUP_DIR"/resolv.conf_* 2>/dev/null | head -1)
        if [[ -n "$latest_backup" ]]; then
            chattr -i /etc/resolv.conf 2>/dev/null || true
            restore_file "/etc/resolv.conf" "$latest_backup"
        fi
    fi

    # Clean up temporary files
    cleanup_temp_files

    print_status "$GREEN" "ShadowCloak stopped and settings restored"
    log_action "ShadowCloak stopped and settings restored"
}

# Update function
update_shadowcloak() {
    print_status "$BLUE" "Updating ShadowCloak..."
    
    if command -v git &> /dev/null; then
        if [[ -d ".git" ]]; then
            git pull origin main
            print_status "$GREEN" "ShadowCloak updated successfully"
        else
            print_status "$YELLOW" "Not a git repository. Manual update required."
        fi
    else
        print_status "$RED" "Git not installed. Cannot auto-update."
    fi
}

# Main function
main() {
    # Check root privileges
    check_root

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --silent)
                SILENT_MODE=true
                shift
                ;;
            --secure-log)
                SECURE_LOG=true
                shift
                ;;
            --iface)
                INTERFACE="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done

    # Setup directories
    setup_directories

    # Handle commands
    case "${1:-start}" in
        start)
            check_dependencies
            interactive_mode
            ;;
        stop)
            stop_shadowcloak
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        update)
            update_shadowcloak
            ;;
        changeid)
            setup_directories
            check_dependencies
            change_identity
            ;;
        
        # Individual feature commands
        tor)
            setup_directories
            check_dependencies
            if start_tor; then
                setup_basic_tor
                print_status "$GREEN" "Tor routing activated"
            fi
            ;;
        mac)
            setup_directories
            randomize_mac
            ;;
        dns)
            setup_directories
            setup_secure_dns
            ;;
        hostname)
            setup_directories
            change_hostname
            ;;
        timezone)
            setup_directories
            randomize_timezone
            ;;
        logs)
            setup_directories
            wipe_logs
            ;;
        browser)
            setup_directories
            harden_browsers
            ;;
        memory)
            setup_directories
            clear_memory
            ;;
        protocols)
            setup_directories
            disable_protocols
            ;;
        
        *)
            print_status "$RED" "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Trap signals for clean exit
trap 'print_status "$YELLOW" "Interrupted. Cleaning up..."; cleanup_temp_files; exit 130' INT TERM

# Run main function with all arguments
main "$@"
