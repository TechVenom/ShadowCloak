#!/bin/bash

#==============================================================================
# ShadowCloak Utilities Module
# Contains utility functions for logging, output, and common operations
#==============================================================================

# Print colored output
print_status() {
    local color=$1
    local message=$2
    if [[ "$SILENT_MODE" != "true" ]]; then
        echo -e "${color}[${SCRIPT_NAME}]${NC} $message"
    fi
}

# Log function with optional encryption
log_action() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] $message"
    
    if [[ "$SECURE_LOG" == "true" ]] && command -v gpg &> /dev/null; then
        # Encrypt log entry
        echo "$log_entry" | gpg --cipher-algo AES256 --compress-algo 1 --symmetric --output - >> "${LOG_FILE}.gpg" 2>/dev/null
    else
        # Standard logging
        echo "$log_entry" >> "$LOG_FILE"
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status "$YELLOW" "This script must be run as root. Attempting to use sudo..."
        exec sudo "$0" "$@"
        exit 1
    fi
}

# Setup directories
setup_directories() {
    mkdir -p "$CONFIG_DIR" "$BACKUP_DIR"
    chmod 700 "$CONFIG_DIR" "$BACKUP_DIR"
}

# Check and install dependencies
check_dependencies() {
    local deps=("${REQUIRED_DEPS[@]}")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_status "$YELLOW" "Installing missing dependencies: ${missing_deps[*]}"
        apt update && apt install -y "${missing_deps[@]}"
        
        # Verify installation
        for dep in "${missing_deps[@]}"; do
            if ! command -v "$dep" &> /dev/null; then
                print_status "$RED" "Failed to install $dep"
                return 1
            fi
        done
    fi
    
    print_status "$GREEN" "All dependencies satisfied"
    return 0
}

# Get active network interface
get_active_interface() {
    if [[ -n "$INTERFACE" ]]; then
        echo "$INTERFACE"
        return 0
    fi
    
    # Find first active interface
    for iface in "${NETWORK_INTERFACES[@]}"; do
        if ip link show "$iface" &>/dev/null; then
            local state=$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)
            if [[ "$state" == "up" ]]; then
                echo "$iface"
                return 0
            fi
        fi
    done
    
    # Fallback to any available interface
    local default_iface=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [[ -n "$default_iface" ]]; then
        echo "$default_iface"
        return 0
    fi
    
    return 1
}

# Generate random string
generate_random_string() {
    local length=${1:-8}
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# Generate random number in range
generate_random_number() {
    local min=${1:-1}
    local max=${2:-100}
    echo $((RANDOM % (max - min + 1) + min))
}

# Check if service is running
is_service_running() {
    local service_name="$1"
    systemctl is-active --quiet "$service_name" 2>/dev/null
}

# Wait for service to start
wait_for_service() {
    local service_name="$1"
    local timeout=${2:-30}
    local count=0
    
    while [[ $count -lt $timeout ]]; do
        if is_service_running "$service_name"; then
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    return 1
}

# Backup file with timestamp
backup_file() {
    local file_path="$1"
    local backup_name="$2"
    
    if [[ -f "$file_path" ]]; then
        local timestamp=$(date '+%Y%m%d_%H%M%S')
        local backup_path="$BACKUP_DIR/${backup_name}_${timestamp}"
        cp "$file_path" "$backup_path"
        log_action "Backed up $file_path to $backup_path"
        echo "$backup_path"
    fi
}

# Restore file from backup
restore_file() {
    local original_path="$1"
    local backup_path="$2"
    
    if [[ -f "$backup_path" ]]; then
        cp "$backup_path" "$original_path"
        log_action "Restored $original_path from $backup_path"
        return 0
    fi
    
    return 1
}

# Clean temporary files
cleanup_temp_files() {
    local temp_dirs=("/tmp" "/var/tmp")
    
    for dir in "${temp_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            find "$dir" -type f -name "shadowcloak_*" -delete 2>/dev/null
        fi
    done
}

# Validate IP address format
validate_ip() {
    local ip="$1"
    local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    if [[ $ip =~ $regex ]]; then
        # Check each octet is <= 255
        IFS='.' read -ra octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if [[ $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    fi
    
    return 1
}

# Show progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%*s" $filled | tr ' ' '='
    printf "%*s" $empty | tr ' ' '-'
    printf "] %d%%" $percentage
}

# Spinner animation
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Export all functions
export -f print_status
export -f log_action
export -f check_root
export -f setup_directories
export -f check_dependencies
export -f get_active_interface
export -f generate_random_string
export -f generate_random_number
export -f is_service_running
export -f wait_for_service
export -f backup_file
export -f restore_file
export -f cleanup_temp_files
export -f validate_ip
export -f show_progress
export -f show_spinner
