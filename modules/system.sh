#!/bin/bash

#==============================================================================
# ShadowCloak System Module
# Contains system functions (logs, memory, protocols)
#==============================================================================

# Wipe system logs
wipe_logs() {
    print_status "$BLUE" "Wiping system logs..."
    
    local log_files=(
        "/var/log/auth.log"
        "/var/log/syslog"
        "/var/log/kern.log"
        "/var/log/boot.log"
        "/var/log/dmesg"
        "/var/log/messages"
        "/var/log/wtmp"
        "/var/log/btmp"
        "/var/log/lastlog"
        "/var/log/faillog"
        "/var/log/utmp"
        "/var/log/apache2/access.log"
        "/var/log/apache2/error.log"
        "/var/log/nginx/access.log"
        "/var/log/nginx/error.log"
    )
    
    # Clear log files
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            > "$log_file"
        fi
    done
    
    # Clear journal logs
    journalctl --vacuum-time=1s &>/dev/null
    
    # Clear bash history
    if [[ -f "$HOME/.bash_history" ]]; then
        > "$HOME/.bash_history"
    fi
    
    # Clear zsh history
    if [[ -f "$HOME/.zsh_history" ]]; then
        > "$HOME/.zsh_history"
    fi
    
    # Clear command history for current session
    history -c
    history -w
    
    print_status "$GREEN" "System logs wiped successfully"
    log_action "System logs wiped"
}

# Clear memory and caches
clear_memory() {
    print_status "$BLUE" "Clearing memory and caches..."
    
    # Sync to ensure all data is written to disk
    sync
    
    # Clear page cache
    echo 1 > /proc/sys/vm/drop_caches
    
    # Clear dentries and inodes
    echo 2 > /proc/sys/vm/drop_caches
    
    # Clear page cache, dentries and inodes
    echo 3 > /proc/sys/vm/drop_caches
    
    # Clear swap if available
    if [[ $(swapon --show | wc -l) -gt 1 ]]; then
        swapoff -a && swapon -a
    fi
    
    # Clear temporary directories
    for temp_dir in "${SYSTEM_LOG_DIRS[@]}"; do
        if [[ -d "$temp_dir" && "$temp_dir" =~ ^/(tmp|var/tmp|.*cache)$ ]]; then
            find "$temp_dir" -type f -atime +1 -delete 2>/dev/null
        fi
    done
    
    # Clear browser caches
    clear_browser_caches
    
    print_status "$GREEN" "Memory and caches cleared successfully"
    log_action "Memory and caches cleared"
}

# Clear browser caches
clear_browser_caches() {
    local user_home="$HOME"
    
    # Firefox cache
    local firefox_cache="$user_home/.cache/mozilla/firefox"
    if [[ -d "$firefox_cache" ]]; then
        rm -rf "$firefox_cache"/*
    fi
    
    # Chrome cache
    local chrome_cache="$user_home/.cache/google-chrome"
    if [[ -d "$chrome_cache" ]]; then
        rm -rf "$chrome_cache"/*
    fi
    
    # Brave cache
    local brave_cache="$user_home/.cache/BraveSoftware"
    if [[ -d "$brave_cache" ]]; then
        rm -rf "$brave_cache"/*
    fi
    
    # Chromium cache
    local chromium_cache="$user_home/.cache/chromium"
    if [[ -d "$chromium_cache" ]]; then
        rm -rf "$chromium_cache"/*
    fi
}

# Secure file deletion
secure_delete() {
    local file_path="$1"
    local passes=${2:-3}
    
    if [[ -f "$file_path" ]]; then
        # Use shred if available
        if command -v shred &> /dev/null; then
            shred -vfz -n "$passes" "$file_path"
        else
            # Fallback method
            for ((i=1; i<=passes; i++)); do
                dd if=/dev/urandom of="$file_path" bs=1024 count=$(du -k "$file_path" | cut -f1) 2>/dev/null
            done
            rm -f "$file_path"
        fi
        
        log_action "Securely deleted: $file_path"
    fi
}

# Wipe free space
wipe_free_space() {
    print_status "$BLUE" "Wiping free space (this may take a while)..."
    
    local temp_file="/tmp/shadowcloak_wipe_$$"
    
    # Fill free space with random data
    dd if=/dev/urandom of="$temp_file" bs=1M 2>/dev/null || true
    
    # Remove the temporary file
    rm -f "$temp_file"
    
    print_status "$GREEN" "Free space wiped successfully"
    log_action "Free space wiped"
}

# Check system security
check_system_security() {
    print_status "$BLUE" "Checking system security..."
    
    local issues=()
    
    # Check for running services that might leak information
    local risky_services=("apache2" "nginx" "ssh" "telnet" "ftp")
    for service in "${risky_services[@]}"; do
        if is_service_running "$service"; then
            issues+=("Service $service is running and might leak information")
        fi
    done
    
    # Check for world-writable files
    local world_writable=$(find /etc /usr /var -type f -perm -002 2>/dev/null | head -5)
    if [[ -n "$world_writable" ]]; then
        issues+=("World-writable files found in system directories")
    fi
    
    # Check for SUID files
    local suid_files=$(find /usr /bin /sbin -type f -perm -4000 2>/dev/null | wc -l)
    if [[ $suid_files -gt 50 ]]; then
        issues+=("High number of SUID files detected: $suid_files")
    fi
    
    # Report findings
    if [[ ${#issues[@]} -eq 0 ]]; then
        print_status "$GREEN" "No obvious security issues detected"
    else
        print_status "$YELLOW" "Security issues detected:"
        for issue in "${issues[@]}"; do
            print_status "$YELLOW" "  - $issue"
        done
    fi
    
    log_action "System security check completed"
}

# Monitor system resources
monitor_resources() {
    print_status "$BLUE" "System Resource Monitor"
    
    # CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    print_status "$CYAN" "CPU Usage: ${cpu_usage}%"
    
    # Memory usage
    local mem_info=$(free -m | grep "Mem:")
    local total_mem=$(echo $mem_info | awk '{print $2}')
    local used_mem=$(echo $mem_info | awk '{print $3}')
    local mem_percent=$((used_mem * 100 / total_mem))
    print_status "$CYAN" "Memory Usage: ${used_mem}MB/${total_mem}MB (${mem_percent}%)"
    
    # Disk usage
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}')
    print_status "$CYAN" "Disk Usage: $disk_usage"
    
    # Network connections
    local connections=$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)
    print_status "$CYAN" "Active Connections: $connections"
    
    # Tor status
    if is_service_running "tor"; then
        print_status "$GREEN" "Tor Status: Running"
    else
        print_status "$RED" "Tor Status: Not Running"
    fi
}

# System hardening
harden_system() {
    print_status "$BLUE" "Applying system hardening..."
    
    # Disable unnecessary services
    local services_to_disable=("bluetooth" "cups" "avahi-daemon")
    for service in "${services_to_disable[@]}"; do
        if systemctl is-enabled "$service" &>/dev/null; then
            systemctl disable "$service" &>/dev/null
            print_status "$GREEN" "Disabled service: $service"
        fi
    done
    
    # Set secure permissions
    chmod 700 /root
    chmod 600 /etc/shadow
    chmod 600 /etc/gshadow
    
    # Configure kernel parameters
    cat >> /etc/sysctl.conf << EOF
# ShadowCloak Security Hardening
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
EOF
    
    sysctl -p &>/dev/null
    
    print_status "$GREEN" "System hardening applied"
    log_action "System hardening applied"
}

# Export all functions
export -f wipe_logs
export -f clear_memory
export -f clear_browser_caches
export -f secure_delete
export -f wipe_free_space
export -f check_system_security
export -f monitor_resources
export -f harden_system
