#!/bin/bash

#==============================================================================
# ShadowCloak Anonymity Module
# Contains anonymity functions (MAC, hostname, timezone)
#==============================================================================

# Backup original MAC address
backup_mac() {
    local iface=$(get_active_interface)
    if [[ -n "$iface" ]]; then
        local original_mac=$(cat "/sys/class/net/$iface/address")
        echo "$iface:$original_mac" > "$ORIGINAL_MAC_FILE"
        log_action "Backed up original MAC for $iface: $original_mac"
    fi
}

# Randomize MAC address
randomize_mac() {
    local iface=$(get_active_interface)
    
    if [[ -z "$iface" ]]; then
        print_status "$RED" "No active network interface found"
        return 1
    fi
    
    # Backup original MAC if not already done
    if [[ ! -f "$ORIGINAL_MAC_FILE" ]]; then
        backup_mac
    fi
    
    print_status "$BLUE" "Randomizing MAC address for $iface..."
    
    # Bring interface down
    ip link set dev "$iface" down
    
    # Generate random MAC address
    local new_mac=$(printf '02:%02x:%02x:%02x:%02x:%02x\n' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    
    # Set new MAC address
    if macchanger -m "$new_mac" "$iface" &>/dev/null; then
        print_status "$GREEN" "MAC address changed to: $new_mac"
    else
        # Fallback method
        ip link set dev "$iface" address "$new_mac"
        print_status "$GREEN" "MAC address changed to: $new_mac (fallback method)"
    fi
    
    # Bring interface back up
    ip link set dev "$iface" up
    
    # Wait for interface to be ready
    sleep 3
    
    log_action "MAC address randomized for $iface: $new_mac"
    return 0
}

# Restore original MAC address
restore_mac() {
    if [[ -f "$ORIGINAL_MAC_FILE" ]]; then
        local iface_mac=$(cat "$ORIGINAL_MAC_FILE")
        local iface=${iface_mac%:*}
        local original_mac=${iface_mac#*:}
        
        if [[ -n "$iface" && -n "$original_mac" ]]; then
            print_status "$BLUE" "Restoring original MAC address for $iface..."
            
            ip link set dev "$iface" down
            macchanger -m "$original_mac" "$iface" &>/dev/null || ip link set dev "$iface" address "$original_mac"
            ip link set dev "$iface" up
            
            print_status "$GREEN" "Original MAC address restored: $original_mac"
            log_action "Original MAC address restored for $iface: $original_mac"
            
            rm -f "$ORIGINAL_MAC_FILE"
        fi
    fi
}

# Backup original hostname
backup_hostname() {
    hostname > "$ORIGINAL_HOSTNAME_FILE"
    log_action "Backed up original hostname: $(cat $ORIGINAL_HOSTNAME_FILE)"
}

# Change hostname
change_hostname() {
    local new_hostname="$1"

    if [[ -z "$new_hostname" ]]; then
        # Generate random hostname
        local prefixes=("desktop" "laptop" "workstation" "pc" "computer" "system")
        local suffixes=("01" "02" "03" "home" "work" "dev")
        local prefix=${prefixes[$RANDOM % ${#prefixes[@]}]}
        local suffix=${suffixes[$RANDOM % ${#suffixes[@]}]}
        new_hostname="${prefix}-${suffix}"
    fi

    # Backup original hostname if not already done
    if [[ ! -f "$ORIGINAL_HOSTNAME_FILE" ]]; then
        backup_hostname
    fi

    print_status "$BLUE" "Changing hostname to: $new_hostname"

    # Change hostname
    hostnamectl set-hostname "$new_hostname"
    
    # Update /etc/hosts
    sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/" /etc/hosts

    print_status "$GREEN" "Hostname changed to: $new_hostname"
    log_action "Hostname changed to: $new_hostname"
}

# Restore original hostname
restore_hostname() {
    if [[ -f "$ORIGINAL_HOSTNAME_FILE" ]]; then
        local original_hostname=$(cat "$ORIGINAL_HOSTNAME_FILE")
        
        print_status "$BLUE" "Restoring original hostname..."
        hostnamectl set-hostname "$original_hostname"
        
        # Update /etc/hosts
        sed -i "s/127.0.1.1.*/127.0.1.1\t$original_hostname/" /etc/hosts
        
        print_status "$GREEN" "Original hostname restored: $original_hostname"
        log_action "Original hostname restored: $original_hostname"
        
        rm -f "$ORIGINAL_HOSTNAME_FILE"
    fi
}

# Backup original timezone
backup_timezone() {
    local current_timezone=$(timedatectl show --property=Timezone --value)
    echo "$current_timezone" > "$ORIGINAL_TIMEZONE_FILE"
    log_action "Backed up original timezone: $current_timezone"
}

# Randomize timezone
randomize_timezone() {
    print_status "$BLUE" "Randomizing timezone..."

    # Backup original timezone if not already done
    if [[ ! -f "$ORIGINAL_TIMEZONE_FILE" ]]; then
        backup_timezone
    fi

    # Select random timezone
    local new_timezone=${TIMEZONES[$RANDOM % ${#TIMEZONES[@]}]}

    # Set new timezone
    timedatectl set-timezone "$new_timezone"

    print_status "$GREEN" "Timezone changed to: $new_timezone"
    log_action "Timezone changed to: $new_timezone"
}

# Restore original timezone
restore_timezone() {
    if [[ -f "$ORIGINAL_TIMEZONE_FILE" ]]; then
        local original_timezone=$(cat "$ORIGINAL_TIMEZONE_FILE")
        
        print_status "$BLUE" "Restoring original timezone..."
        timedatectl set-timezone "$original_timezone"
        
        print_status "$GREEN" "Original timezone restored: $original_timezone"
        log_action "Original timezone restored: $original_timezone"
        
        rm -f "$ORIGINAL_TIMEZONE_FILE"
    fi
}

# Change identity (combined MAC and Tor identity change)
change_identity() {
    print_status "$CYAN" "Changing complete identity..."

    # Change Tor identity
    change_tor_identity

    # Randomize MAC address
    randomize_mac

    print_status "$GREEN" "Identity changed successfully"
    log_action "Identity changed"
}

# Export all functions
export -f backup_mac
export -f randomize_mac
export -f restore_mac
export -f backup_hostname
export -f change_hostname
export -f restore_hostname
export -f backup_timezone
export -f randomize_timezone
export -f restore_timezone
export -f change_identity
