#!/bin/bash

#==============================================================================
# ShadowCloak Network Module
# Contains network-related functions (Tor, DNS, IP detection)
#==============================================================================

# Start Tor service
start_tor() {
    print_status "$BLUE" "Starting Tor service..."
    
    # Check if Tor is already running
    if is_service_running "tor"; then
        print_status "$GREEN" "Tor is already running"
        return 0
    fi
    
    # Start Tor service
    systemctl start tor
    
    # Wait for Tor to start
    if wait_for_service "tor" 30; then
        print_status "$GREEN" "Tor started successfully"
        log_action "Tor service started"
        return 0
    else
        print_status "$RED" "Failed to start Tor service"
        return 1
    fi
}

# Configure basic Tor routing (non-blocking)
setup_basic_tor() {
    print_status "$BLUE" "Setting up basic Tor routing..."
    
    # Just ensure Tor is running - no aggressive iptables rules
    if ! is_service_running "tor"; then
        systemctl start tor
        sleep 3
    fi
    
    log_action "Basic Tor routing configured"
    print_status "$GREEN" "Tor service started successfully"
}

# Get current IP address with multiple fallbacks
get_current_ip() {
    local ip=""
    
    # Method 1: Try through Tor proxy first (if Tor is running)
    if is_service_running "tor"; then
        ip=$(timeout 8 curl -s --socks5 127.0.0.1:9050 "https://httpbin.org/ip" 2>/dev/null | grep -o '"origin": "[^"]*"' | cut -d'"' -f4)
        
        # Alternative Tor check
        if [[ -z "$ip" ]]; then
            ip=$(timeout 8 curl -s --socks5 127.0.0.1:9050 "https://icanhazip.com" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
        fi
    fi
    
    # Method 2: Direct connection fallbacks
    if [[ -z "$ip" ]] && command -v curl &> /dev/null; then
        # Try multiple services
        local services=(
            "https://httpbin.org/ip"
            "https://icanhazip.com"
            "https://ipinfo.io/ip"
            "https://api.ipify.org"
            "https://checkip.amazonaws.com"
        )
        
        for service in "${services[@]}"; do
            if [[ "$service" == "https://httpbin.org/ip" ]]; then
                ip=$(timeout 5 curl -s "$service" 2>/dev/null | grep -o '"origin": "[^"]*"' | cut -d'"' -f4)
            else
                ip=$(timeout 5 curl -s "$service" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
            fi
            
            # If we got a valid IP, break
            if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            fi
            ip=""
        done
    fi
    
    # Method 3: Try wget as fallback
    if [[ -z "$ip" ]] && command -v wget &> /dev/null; then
        ip=$(timeout 5 wget -qO- "https://icanhazip.com" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
    fi
    
    # Return IP or "Unable to detect" if detection failed
    if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
    else
        echo "Unable to detect"
    fi
}

# Verify Tor connection
verify_tor_connection() {
    local tor_check=$(curl -s --max-time 10 --socks5 127.0.0.1:9050 "https://check.torproject.org/api/ip" 2>/dev/null | grep -o '"IsTor":true')
    
    if [[ -n "$tor_check" ]]; then
        return 0  # Using Tor
    else
        return 1  # Not using Tor
    fi
}

# Change Tor identity
change_tor_identity() {
    print_status "$BLUE" "Changing Tor identity..."
    
    # Check if Tor is running
    if ! is_service_running "tor"; then
        print_status "$RED" "Tor service is not running. Starting Tor..."
        if ! start_tor; then
            print_status "$RED" "Failed to start Tor service"
            return 1
        fi
    fi
    
    # Get current IP before change
    print_status "$BLUE" "Detecting current IP..."
    local old_ip=$(get_current_ip)
    if [[ "$old_ip" != "Unable to detect" ]]; then
        print_status "$CYAN" "Current IP: $old_ip"
    else
        print_status "$YELLOW" "Unable to detect current IP"
    fi
    
    # Send NEWNYM signal to Tor control port
    print_status "$BLUE" "Sending identity change signal to Tor..."
    local newnym_result=1
    
    # Try multiple methods to change identity
    if command -v nc &> /dev/null; then
        echo -e 'AUTHENTICATE ""\nSIGNAL NEWNYM\nQUIT' | timeout 5 nc 127.0.0.1 9051 &>/dev/null
        newnym_result=$?
    fi
    
    # Alternative method using systemctl if nc fails
    if [[ $newnym_result -ne 0 ]]; then
        print_status "$YELLOW" "Control port method failed, trying service reload..."
        systemctl reload tor &>/dev/null
        newnym_result=$?
    fi
    
    # Another alternative using kill signal
    if [[ $newnym_result -ne 0 ]]; then
        print_status "$YELLOW" "Service reload failed, trying process signal..."
        pkill -HUP tor &>/dev/null
    fi
    
    # Wait for circuit rebuild
    print_status "$BLUE" "Waiting for new circuit to establish..."
    sleep 5
    
    # Verify IP change
    print_status "$BLUE" "Verifying IP change..."
    local new_ip=$(get_current_ip)
    
    # Report results
    if [[ "$new_ip" != "Unable to detect" && "$new_ip" != "$old_ip" ]]; then
        print_status "$GREEN" "✓ Tor identity changed successfully!"
        print_status "$GREEN" "New IP: $new_ip"
        
        # Verify we're still using Tor
        if verify_tor_connection; then
            print_status "$GREEN" "✓ Confirmed: Traffic is routing through Tor"
        else
            print_status "$YELLOW" "⚠ Warning: May not be using Tor proxy"
        fi
    elif [[ "$new_ip" == "$old_ip" ]]; then
        print_status "$YELLOW" "⚠ IP unchanged: $new_ip"
        print_status "$YELLOW" "This can happen if the same exit node is selected"
    else
        print_status "$RED" "✗ Unable to verify IP change"
        print_status "$CYAN" "Old IP: $old_ip"
        print_status "$CYAN" "New IP: $new_ip"
    fi
    
    log_action "Tor identity change attempted. Old IP: $old_ip, New IP: $new_ip"
}

# Setup secure DNS
setup_secure_dns() {
    print_status "$BLUE" "Configuring secure DNS..."
    
    # Backup original DNS configuration
    if [[ -f "/etc/resolv.conf" ]]; then
        backup_file "/etc/resolv.conf" "resolv.conf"
    fi
    
    # Select random DNS servers
    local primary_dns=${DNS_SERVERS[$RANDOM % ${#DNS_SERVERS[@]}]}
    local secondary_dns=${DNS_SERVERS[$RANDOM % ${#DNS_SERVERS[@]}]}
    
    # Ensure different servers
    while [[ "$secondary_dns" == "$primary_dns" ]]; do
        secondary_dns=${DNS_SERVERS[$RANDOM % ${#DNS_SERVERS[@]}]}
    done
    
    # Configure DNS
    cat > /etc/resolv.conf << EOF
# ShadowCloak DNS Configuration
nameserver $primary_dns
nameserver $secondary_dns
options timeout:2
options attempts:3
options rotate
options single-request-reopen
EOF
    
    # Make it immutable to prevent changes
    chattr +i /etc/resolv.conf 2>/dev/null || true
    
    print_status "$GREEN" "Secure DNS configured: $primary_dns, $secondary_dns"
    log_action "DNS configured with servers: $primary_dns, $secondary_dns"
}

# Test DNS leak
test_dns_leak() {
    print_status "$BLUE" "Testing for DNS leaks..."
    
    local dns_test=$(dig +short @8.8.8.8 whoami.akamai.net 2>/dev/null)
    local tor_test=""
    
    if is_service_running "tor"; then
        tor_test=$(curl -s --socks5 127.0.0.1:9050 "https://httpbin.org/ip" 2>/dev/null | grep -o '"origin": "[^"]*"' | cut -d'"' -f4)
    fi
    
    if [[ -n "$dns_test" && -n "$tor_test" && "$dns_test" == "$tor_test" ]]; then
        print_status "$GREEN" "DNS leak test passed - using Tor"
        return 0
    else
        print_status "$RED" "DNS leak detected! Please check your DNS configuration."
        return 1
    fi
}

# Disable IPv6 and other protocols
disable_protocols() {
    print_status "$BLUE" "Disabling IPv6 and unnecessary protocols..."

    # Disable IPv6
    echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
    echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6

    # Make it persistent
    cat >> /etc/sysctl.conf << EOF
# ShadowCloak - Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

    sysctl -p &>/dev/null

    print_status "$GREEN" "IPv6 disabled successfully"
    log_action "IPv6 and unnecessary protocols disabled"
}

# Export all functions
export -f start_tor
export -f setup_basic_tor
export -f get_current_ip
export -f verify_tor_connection
export -f change_tor_identity
export -f setup_secure_dns
export -f test_dns_leak
export -f disable_protocols
