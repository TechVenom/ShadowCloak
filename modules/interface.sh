#!/bin/bash

#==============================================================================
# ShadowCloak Interface Module
# Contains user interface and menu functions
#==============================================================================

# Show startup animation
show_startup_animation() {
    clear

    # Loading animation
    echo -e "${BLUE}[*] Initializing ShadowCloak..."
    sleep 0.5

    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    for i in {1..20}; do
        local char_index=$((i % ${#chars}))
        printf "\r${BLUE}[${chars:$char_index:1}] Loading privacy modules...${NC}"
        sleep 0.1
    done
    printf "\r${GREEN}[✓] Privacy modules loaded successfully!${NC}\n"
    sleep 0.5

    echo -e "${BLUE}[*] Preparing anonymity toolkit..."
    sleep 0.3
    echo -e "${GREEN}[✓] ShadowCloak ready for deployment!${NC}"
    sleep 0.5
}

# Show animated banner
show_banner() {
    clear

    # Animated ASCII Art Banner
    echo -e "${CYAN}"
    echo ""
    echo "  ███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗ ██████╗██╗      ██████╗  █████╗ ██╗  ██╗"
    echo "  ██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║██╔════╝██║     ██╔═══██╗██╔══██╗██║ ██╔╝"
    echo "  ███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║██║     ██║     ██║   ██║███████║█████╔╝ "
    echo "  ╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║██║     ██║     ██║   ██║██╔══██║██╔═██╗ "
    echo "  ███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝╚██████╗███████╗╚██████╔╝██║  ██║██║  ██╗"
    echo "  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝  ╚═════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo ""
    echo -e "                    ${GREEN}Advanced Privacy & Anonymity Toolkit v${VERSION}${NC}"
    echo -e "                    ${YELLOW}Professional Cybersecurity Suite${NC}"
    echo ""
    echo -e "                    ${WHITE}═══════════════════════════════════════${NC}"
    echo -e "                    ${WHITE}Author: ${GREEN}Hezron Paipai (TechVenom)${NC}"
    echo -e "                    ${WHITE}GitHub: ${CYAN}https://github.com/TechVenom${NC}"
    echo -e "                    ${WHITE}Email:  ${BLUE}gptboy47@gmail.com${NC}"
    echo -e "                    ${WHITE}═══════════════════════════════════════${NC}"
    echo ""
}

# Show help
show_help() {
    show_banner
    echo -e "${WHITE}Usage: ${GREEN}$0 ${YELLOW}[COMMAND] [OPTIONS]${NC}"
    echo ""
    echo -e "${WHITE}Commands:${NC}"
    echo -e "    ${GREEN}start${NC}      Start interactive mode"
    echo -e "    ${GREEN}tor${NC}        Enable Tor routing only"
    echo -e "    ${GREEN}mac${NC}        Randomize MAC address only"
    echo -e "    ${GREEN}dns${NC}        Configure secure DNS only"
    echo -e "    ${GREEN}hostname${NC}   Change hostname only"
    echo -e "    ${GREEN}timezone${NC}   Randomize timezone only"
    echo -e "    ${GREEN}logs${NC}       Wipe system logs only"
    echo -e "    ${GREEN}browser${NC}    Harden browsers only"
    echo -e "    ${GREEN}memory${NC}     Clear memory and caches only"
    echo -e "    ${GREEN}protocols${NC}  Disable IPv6 and protocols only"
    echo -e "    ${GREEN}changeid${NC}   Change Tor identity and MAC address"
    echo -e "    ${GREEN}status${NC}     Show current IP, MAC, hostname, and Tor status"
    echo -e "    ${GREEN}stop${NC}       Stop all services and restore settings"
    echo -e "    ${GREEN}update${NC}     Self-update from Git repository"
    echo -e "    ${GREEN}help${NC}       Display this help message"
    echo ""
    echo -e "${WHITE}Options:${NC}"
    echo -e "    ${GREEN}--silent${NC}   Run in silent mode (no prompts)"
    echo -e "    ${GREEN}--secure-log${NC} Enable encrypted logging"
    echo -e "    ${GREEN}--iface${NC} ${YELLOW}INTERFACE${NC} Specify network interface"
    echo ""
    echo -e "${WHITE}Examples:${NC}"
    echo -e "    ${CYAN}$0 start${NC}                    # Interactive mode"
    echo -e "    ${CYAN}$0 start --silent${NC}           # Silent mode with all features"
    echo -e "    ${CYAN}$0 tor --iface wlan0${NC}        # Enable Tor on specific interface"
    echo -e "    ${CYAN}$0 status${NC}                   # Show current status"
    echo ""
}

# Show feature selection menu
show_feature_menu() {
    show_banner
    echo -e "${WHITE}Select features to activate:${NC}"
    echo ""
    echo "1) Tor Routing - Route traffic through Tor network"
    echo "2) MAC Randomization - Change MAC address for anonymity"
    echo "3) DNS Protection - Use secure DNS servers"
    echo "4) Hostname Camouflage - Change system hostname"
    echo "5) Timezone Randomization - Randomize system timezone"
    echo "6) Log Wiping - Clear system and application logs"
    echo "7) Browser Hardening - Configure browsers for anonymity"
    echo "8) Memory Clearing - Wipe RAM and clear caches"
    echo "9) Protocol Hardening - Disable IPv6 and unnecessary protocols"
    echo ""
    echo "a) Select ALL features"
    echo "q) Quit"
    echo ""
}

# Get user feature selection
get_feature_selection() {
    local selected_features=()
    
    while true; do
        show_feature_menu
        echo -n "Enter your choices (e.g., 1,3,5 or 'a' for all): "
        read -r user_input
        
        case "$user_input" in
            q|Q)
                print_status "$YELLOW" "Exiting..."
                exit 0
                ;;
            a|A)
                selected_features=(0 1 2 3 4 5 6 7 8)
                break
                ;;
            *)
                # Parse comma-separated choices
                IFS=',' read -ra choices <<< "$user_input"
                local valid=true
                
                for choice in "${choices[@]}"; do
                    # Remove spaces
                    choice=$(echo "$choice" | tr -d ' ')
                    if [[ "$choice" =~ ^[1-9]$ ]]; then
                        selected_features+=($((choice-1)))
                    else
                        print_status "$RED" "Invalid choice: $choice"
                        valid=false
                        break
                    fi
                done
                
                if [[ "$valid" == "true" ]]; then
                    break
                fi
                ;;
        esac
    done
    
    # Remove duplicates and sort
    selected_features=($(printf '%s\n' "${selected_features[@]}" | sort -nu))
    
    # Set global variable
    SELECTED_FEATURES=("${selected_features[@]}")
}

# Show selected features confirmation
show_confirmation() {
    local feature_names=("${FEATURE_NAMES[@]}")
    
    echo ""
    echo -e "${WHITE}Selected features:${NC}"
    for index in "${SELECTED_FEATURES[@]}"; do
        echo -e "  ${GREEN}✓${NC} ${feature_names[$index]}"
    done
    echo ""
    
    if [[ "$SILENT_MODE" != "true" ]]; then
        echo -n "Proceed with activation? (y/N): "
        read -r confirm
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_status "$YELLOW" "Operation cancelled"
            exit 0
        fi
    fi
}

# Execute selected features
execute_features() {
    local feature_names=("${FEATURE_NAMES[@]}")
    
    print_status "$CYAN" "Activating selected features..."
    echo ""
    
    for index in "${SELECTED_FEATURES[@]}"; do
        print_status "$BLUE" "Activating: ${feature_names[$index]}"
        
        case $index in
            0) # Tor Routing
                if ! start_tor; then
                    print_status "$RED" "Failed to start Tor. Continuing with other features..."
                else
                    setup_basic_tor
                fi
                ;;
            1) # MAC Randomization
                randomize_mac
                ;;
            2) # DNS Protection
                setup_secure_dns
                ;;
            3) # Hostname Camouflage
                change_hostname
                ;;
            4) # Timezone Randomization
                randomize_timezone
                ;;
            5) # Log Wiping
                wipe_logs
                ;;
            6) # Browser Hardening
                harden_browsers
                ;;
            7) # Memory Clearing
                clear_memory
                ;;
            8) # Protocol Hardening
                disable_protocols
                ;;
        esac
        
        echo ""
    done
    
    print_status "$GREEN" "All selected features activated successfully!"
}

# Show current status
show_status() {
    show_banner

    print_status "$CYAN" "Current System Status:"
    echo ""
    
    # IP Address
    local current_ip=$(get_current_ip)
    if [[ "$current_ip" != "Unable to detect" ]]; then
        print_status "$GREEN" "Current IP: $current_ip"
        
        # Check if using Tor
        if verify_tor_connection; then
            print_status "$GREEN" "✓ Traffic is routing through Tor"
        else
            print_status "$YELLOW" "⚠ Not using Tor proxy"
        fi
    else
        print_status "$RED" "Unable to detect current IP"
    fi
    
    # MAC Address
    local iface=$(get_active_interface)
    if [[ -n "$iface" ]]; then
        local current_mac=$(cat "/sys/class/net/$iface/address" 2>/dev/null)
        print_status "$GREEN" "MAC Address ($iface): $current_mac"
    fi
    
    # Hostname
    local current_hostname=$(hostname)
    print_status "$GREEN" "Hostname: $current_hostname"
    
    # Timezone
    local current_timezone=$(timedatectl show --property=Timezone --value)
    print_status "$GREEN" "Timezone: $current_timezone"
    
    # Tor Service Status
    if is_service_running "tor"; then
        print_status "$GREEN" "Tor Service: Running"
    else
        print_status "$RED" "Tor Service: Not Running"
    fi
    
    # DNS Configuration
    local dns_servers=$(grep "^nameserver" /etc/resolv.conf 2>/dev/null | awk '{print $2}' | tr '\n' ' ')
    if [[ -n "$dns_servers" ]]; then
        print_status "$GREEN" "DNS Servers: $dns_servers"
    fi
    
    echo ""
}

# Interactive mode
interactive_mode() {
    if [[ "$SILENT_MODE" == "true" ]]; then
        # Silent mode - activate all features
        show_startup_animation
        SELECTED_FEATURES=(0 1 2 3 4 5 6 7 8)
        show_confirmation
        execute_features
    else
        # Interactive mode with animation
        show_startup_animation
        get_feature_selection
        show_confirmation
        execute_features
    fi
}

# Progress indicator for long operations
show_operation_progress() {
    local operation="$1"
    local duration=${2:-5}
    
    print_status "$BLUE" "$operation"
    
    for ((i=1; i<=duration; i++)); do
        printf "."
        sleep 1
    done
    
    echo ""
}

# Export all functions
export -f show_startup_animation
export -f show_banner
export -f show_help
export -f show_feature_menu
export -f get_feature_selection
export -f show_confirmation
export -f execute_features
export -f show_status
export -f interactive_mode
export -f show_operation_progress
