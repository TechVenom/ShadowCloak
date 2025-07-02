#!/bin/bash

#==============================================================================
# ShadowCloak Browser Module
# Contains browser hardening and privacy functions
#==============================================================================

# Configure Firefox for privacy
configure_firefox() {
    print_status "$BLUE" "Configuring Firefox for privacy..."
    
    local firefox_profiles_dir="$HOME/.mozilla/firefox"
    
    if [[ ! -d "$firefox_profiles_dir" ]]; then
        print_status "$YELLOW" "Firefox not found or not configured"
        return 1
    fi
    
    # Find default profile
    local profile_dir=$(find "$firefox_profiles_dir" -name "*.default*" -type d | head -1)
    
    if [[ -z "$profile_dir" ]]; then
        print_status "$YELLOW" "No Firefox profile found"
        return 1
    fi
    
    # Create user.js with privacy settings
    cat > "$profile_dir/user.js" << 'EOF'
// ShadowCloak Firefox Privacy Configuration

// Disable telemetry
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.server", "");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);

// Disable location services
user_pref("geo.enabled", false);
user_pref("geo.provider.network.url", "");
user_pref("browser.search.geoip.url", "");

// Disable WebRTC
user_pref("media.peerconnection.enabled", false);
user_pref("media.peerconnection.ice.default_address_only", true);

// Disable WebGL
user_pref("webgl.disabled", true);

// Disable JavaScript in PDFs
user_pref("pdfjs.enableScripting", false);

// Disable auto-fill
user_pref("browser.formfill.enable", false);
user_pref("signon.rememberSignons", false);

// Disable prefetching
user_pref("network.dns.disablePrefetch", true);
user_pref("network.prefetch-next", false);

// Disable tracking
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.donottrackheader.enabled", true);

// Disable WebSockets
user_pref("network.websocket.enabled", false);

// Disable camera and microphone
user_pref("media.navigator.enabled", false);

// Disable battery API
user_pref("dom.battery.enabled", false);

// Disable gamepad API
user_pref("dom.gamepad.enabled", false);

// Disable clipboard events
user_pref("dom.event.clipboardevents.enabled", false);

// Disable push notifications
user_pref("dom.push.enabled", false);

// Use HTTPS-Only mode
user_pref("dom.security.https_only_mode", true);

// Disable automatic connections
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("browser.places.speculativeConnect.enabled", false);

// Clear data on shutdown
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown.cache", true);
user_pref("privacy.clearOnShutdown.cookies", true);
user_pref("privacy.clearOnShutdown.downloads", true);
user_pref("privacy.clearOnShutdown.formdata", true);
user_pref("privacy.clearOnShutdown.history", true);
user_pref("privacy.clearOnShutdown.sessions", true);

// Resist fingerprinting
user_pref("privacy.resistFingerprinting", true);
user_pref("privacy.resistFingerprinting.letterboxing", true);

// Disable safe browsing
user_pref("browser.safebrowsing.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
EOF
    
    print_status "$GREEN" "Firefox configured for privacy"
    log_action "Firefox privacy configuration applied"
}

# Configure Chrome/Chromium for privacy
configure_chrome() {
    print_status "$BLUE" "Configuring Chrome for privacy..."
    
    local chrome_dirs=(
        "$HOME/.config/google-chrome"
        "$HOME/.config/chromium"
        "$HOME/.config/BraveSoftware/Brave-Browser"
    )
    
    local configured=false
    
    for chrome_dir in "${chrome_dirs[@]}"; do
        if [[ -d "$chrome_dir" ]]; then
            local prefs_file="$chrome_dir/Default/Preferences"
            
            if [[ -f "$prefs_file" ]]; then
                # Backup original preferences
                backup_file "$prefs_file" "chrome_preferences"
                
                # Apply privacy settings using jq if available
                if command -v jq &> /dev/null; then
                    local temp_prefs="/tmp/chrome_prefs_$$"
                    jq '. + {
                        "profile": {
                            "default_content_setting_values": {
                                "geolocation": 2,
                                "media_stream_camera": 2,
                                "media_stream_mic": 2,
                                "notifications": 2,
                                "plugins": 2
                            }
                        },
                        "privacy": {
                            "enable_do_not_track": true,
                            "safe_browsing_enabled": false
                        },
                        "webkit": {
                            "webprefs": {
                                "javascript_enabled": true,
                                "web_security_enabled": true
                            }
                        }
                    }' "$prefs_file" > "$temp_prefs" && mv "$temp_prefs" "$prefs_file"
                fi
                
                configured=true
                print_status "$GREEN" "Chrome/Chromium configured: $(basename "$chrome_dir")"
            fi
        fi
    done
    
    if [[ "$configured" == "true" ]]; then
        log_action "Chrome/Chromium privacy configuration applied"
    else
        print_status "$YELLOW" "No Chrome/Chromium installations found"
    fi
}

# Install and configure Tor Browser
install_tor_browser() {
    print_status "$BLUE" "Installing Tor Browser..."
    
    local tor_browser_dir="/opt/tor-browser"
    local download_url="https://www.torproject.org/dist/torbrowser/12.5.6/tor-browser-linux64-12.5.6_ALL.tar.xz"
    local temp_file="/tmp/tor-browser.tar.xz"
    
    # Download Tor Browser
    if curl -L -o "$temp_file" "$download_url"; then
        # Extract to /opt
        mkdir -p "$tor_browser_dir"
        tar -xf "$temp_file" -C "$tor_browser_dir" --strip-components=1
        
        # Set permissions
        chmod +x "$tor_browser_dir/start-tor-browser.desktop"
        
        # Create desktop shortcut
        cat > "$HOME/Desktop/tor-browser.desktop" << EOF
[Desktop Entry]
Name=Tor Browser
Comment=Anonymous web browsing
Exec=$tor_browser_dir/start-tor-browser.desktop
Icon=$tor_browser_dir/Browser/browser/chrome/icons/default/default128.png
Type=Application
Categories=Network;WebBrowser;
EOF
        
        chmod +x "$HOME/Desktop/tor-browser.desktop"
        
        # Cleanup
        rm -f "$temp_file"
        
        print_status "$GREEN" "Tor Browser installed successfully"
        log_action "Tor Browser installed"
    else
        print_status "$RED" "Failed to download Tor Browser"
        return 1
    fi
}

# Clear browser data
clear_browser_data() {
    print_status "$BLUE" "Clearing browser data..."
    
    # Firefox
    local firefox_profile_dir=$(find "$HOME/.mozilla/firefox" -name "*.default*" -type d 2>/dev/null | head -1)
    if [[ -n "$firefox_profile_dir" ]]; then
        rm -rf "$firefox_profile_dir/cache2"/*
        rm -rf "$firefox_profile_dir/cookies.sqlite"
        rm -rf "$firefox_profile_dir/formhistory.sqlite"
        rm -rf "$firefox_profile_dir/places.sqlite"
        print_status "$GREEN" "Firefox data cleared"
    fi
    
    # Chrome/Chromium
    local chrome_dirs=(
        "$HOME/.config/google-chrome/Default"
        "$HOME/.config/chromium/Default"
        "$HOME/.config/BraveSoftware/Brave-Browser/Default"
    )
    
    for chrome_dir in "${chrome_dirs[@]}"; do
        if [[ -d "$chrome_dir" ]]; then
            rm -rf "$chrome_dir/Cache"/*
            rm -rf "$chrome_dir/Cookies"
            rm -rf "$chrome_dir/History"
            rm -rf "$chrome_dir/Web Data"
            print_status "$GREEN" "Chrome data cleared: $(basename "$(dirname "$chrome_dir")")"
        fi
    done
    
    log_action "Browser data cleared"
}

# Configure browser proxy settings
configure_browser_proxy() {
    print_status "$BLUE" "Configuring browser proxy settings..."
    
    # Firefox proxy configuration
    local firefox_profile_dir=$(find "$HOME/.mozilla/firefox" -name "*.default*" -type d 2>/dev/null | head -1)
    if [[ -n "$firefox_profile_dir" ]]; then
        cat >> "$firefox_profile_dir/user.js" << EOF

// ShadowCloak Proxy Configuration
user_pref("network.proxy.type", 1);
user_pref("network.proxy.socks", "127.0.0.1");
user_pref("network.proxy.socks_port", 9050);
user_pref("network.proxy.socks_version", 5);
user_pref("network.proxy.socks_remote_dns", true);
user_pref("network.proxy.no_proxies_on", "");
EOF
        print_status "$GREEN" "Firefox proxy configured"
    fi
    
    log_action "Browser proxy settings configured"
}

# Harden all browsers
harden_browsers() {
    print_status "$BLUE" "Hardening all browsers..."
    
    configure_firefox
    configure_chrome
    configure_browser_proxy
    clear_browser_data
    
    print_status "$GREEN" "Browser hardening completed"
    log_action "Browser hardening completed"
}

# Check browser security
check_browser_security() {
    print_status "$BLUE" "Checking browser security..."
    
    local issues=()
    
    # Check for saved passwords
    local firefox_profile_dir=$(find "$HOME/.mozilla/firefox" -name "*.default*" -type d 2>/dev/null | head -1)
    if [[ -n "$firefox_profile_dir" && -f "$firefox_profile_dir/logins.json" ]]; then
        local saved_logins=$(jq '.logins | length' "$firefox_profile_dir/logins.json" 2>/dev/null || echo "0")
        if [[ $saved_logins -gt 0 ]]; then
            issues+=("Firefox has $saved_logins saved passwords")
        fi
    fi
    
    # Check for browser extensions
    if [[ -n "$firefox_profile_dir" && -d "$firefox_profile_dir/extensions" ]]; then
        local extension_count=$(ls -1 "$firefox_profile_dir/extensions" 2>/dev/null | wc -l)
        if [[ $extension_count -gt 0 ]]; then
            issues+=("Firefox has $extension_count extensions installed")
        fi
    fi
    
    # Report findings
    if [[ ${#issues[@]} -eq 0 ]]; then
        print_status "$GREEN" "No browser security issues detected"
    else
        print_status "$YELLOW" "Browser security issues detected:"
        for issue in "${issues[@]}"; do
            print_status "$YELLOW" "  - $issue"
        done
    fi
    
    log_action "Browser security check completed"
}

# Export all functions
export -f configure_firefox
export -f configure_chrome
export -f install_tor_browser
export -f clear_browser_data
export -f configure_browser_proxy
export -f harden_browsers
export -f check_browser_security
