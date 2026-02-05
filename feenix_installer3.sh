#!/usr/bin/env bash
# =============================================================================
# Feenix Anonimizer Full Setup Installer for Kali Linux
# =============================================================================

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────────
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

TARGET_DIR="/home/Feenix_Anonimizer_v4.3"
BACKUP_DIR="$TARGET_DIR/proxychain_backup"
SCRIPT_NAME="feenix_V4.3.sh"
SCRIPT_PATH="$TARGET_DIR/$SCRIPT_NAME"
PROXYCHAINS_CONF_ORIG="/etc/proxychains4.conf"
PROXYCHAINS_CONF_TARGET="$TARGET_DIR/proxychains4.conf"

clear
echo -e "${CYAN}${BOLD}"
echo "===================================================="
echo "     Feenix Anonimizer v4.3 - FULL SETUP INSTALLER"
echo "           Developed by Pawan Sandeepa"
echo "===================================================="
echo -e "${RESET}"

# Must be root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR] This installer must be run as root${RESET}"
    echo -e "${YELLOW}        Use: sudo bash $0${RESET}"
    exit 1
fi

echo -e "${BLUE}[1/7] Updating Kali package lists...${RESET}"
echo -e "${BLUE}──────────────────────────────────────${RESET}"
apt update -y
echo

echo -e "${BLUE}[2/7] Installing required anonymity & networking tools...${RESET}"
echo -e "${BLUE}────────────────────────────────────────────────────────────${RESET}"

apt install -y --no-install-recommends \
    macchanger \
    openvpn \
    tor \
    torsocks \
    proxychains4 \
    torbrowser-launcher || true

echo
echo -e "${BLUE}[3/7] Verifying installed packages...${RESET}"
echo -e "${BLUE}──────────────────────────────────────${RESET}"

for pkg in macchanger openvpn tor torsocks proxychains4 torbrowser-launcher; do
    if dpkg -s "$pkg" &>/dev/null; then
        echo -e "${YELLOW}[OK] $pkg is installed${RESET}"
    else
        echo -e "${RED}[ERROR] $pkg is NOT installed${RESET}"
    fi
done

echo

echo -e "${BLUE}[4/7] Creating Feenix directory:${RESET} ${CYAN}$TARGET_DIR${RESET}"
mkdir -p "$TARGET_DIR" "$BACKUP_DIR"
chmod 755 "$TARGET_DIR" "$BACKUP_DIR"

# ─────────────────────────────────────────────────────────────
# Proxychains configuration
# ─────────────────────────────────────────────────────────────
echo
echo -e "${BLUE}[5/7] Handling proxychains configuration...${RESET}"

if [[ -f "$PROXYCHAINS_CONF_ORIG" ]]; then
    echo -e "${CYAN}→ Backing up original proxychains4.conf${RESET}"
    cp -f "$PROXYCHAINS_CONF_ORIG" "$BACKUP_DIR/proxychains4.conf"
    cp -f "$PROXYCHAINS_CONF_ORIG" "$TARGET_DIR/proxychains4.conf"
    echo -e "${GREEN}✓ Backup completed${RESET}"
else
    echo -e "${YELLOW}⚠ Warning: /etc/proxychains4.conf not found — skipping backup${RESET}"
fi

echo -e "${CYAN}→ Creating custom proxychains4.conf${RESET}"

cat > "$PROXYCHAINS_CONF_TARGET" << 'EOF'
dynamic_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
http   192.145.31.78    8080
socks4 184.181.217.213  4145
socks4 192.252.214.20  15864
EOF

chmod 644 "$PROXYCHAINS_CONF_TARGET"
echo -e "${GREEN}✓ Custom proxychains config created${RESET}"

# Remove old script if exists
[[ -f "$SCRIPT_PATH" ]] && rm -f "$SCRIPT_PATH"

echo
echo -e "${BLUE}[6/7] Creating main script:${RESET} ${CYAN}$SCRIPT_PATH${RESET}"

cat > "$SCRIPT_PATH" << 'END_OF_FEENIX_SCRIPT'
#!/bin/bash
# =========================================================
# Feenix Anonimizer 2.6v
# Developed by: Pawan Sandeepa
# Safe Template Version (No harmful automation)
# =========================================================
# Hacker Colors
GREEN="\e[92m"
CYAN="\e[96m"
RED="\e[91m"
RESET="\e[0m"
# ProxyChains config paths
PROXY_ETC="/etc/proxychains4.conf"
PROXY_ETC_DIR="/etc"
PROXY_CUSTOM="/Feenix_Anonimizer/proxychains4.conf"
PROXY_BACKUP="/Feenix_Anonimizer/proxychain_backup/proxychains4.conf"
# Global Variables for Status
ORIGINAL_INTERFACE=""
ORIGINAL_MAC=""
MAC_CHANGED=false
# Public/Exit IP status
CURRENT_PUBLIC_IP=""
EXIT_NODE_IP=""
# ProxyChains status
PROXYCHAINS_ENABLED=""
PROXYCHAINS_PATH=""
PROXYCHAINS_APP=""
# Network repair status
NETWORK_REPAIRED=""
#vpn country
VPN_CONNECTED=false
VPN_COUNTRY=""
# Logging Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/feenix_anonimizer.log"
#ASCII_ART_FILE="$SCRIPT_DIR/ascii-art.txt"
read -r -d '' BANNER_ASCII <<'EOF'                                                       
.                       %%%%%%%%%*                      
                   #%%%%####%%%%%%%%                   
                 %%%#*######%%###%%%%%#                
               %%%##**######%%%%%##%%%%%#              
             %%%###***######%%%%%%#%###%%%             
            %%#*******######%%%%%%#%%%##%%%#           
           %%**#***######*****#%%%##%**#%##%*          
          %%###+**###**+*%%%%%#***%%%##**%#%%          
         #%%**####***#%%#******#%%#**%%%%#**%%         
         %%*###*+*#%%*****+++*****#%%#+*%%%#*%#        
        %%###***%%#*+++          *++*#%%**%##%%%       
       %%##*+#%%**++***=        +**++*+#%%***#%%       
      %%#*+#%#######%%%#+      *%%%%#####*%%**#%%      
     *%%*+%%***     ++*%%-   -%%#*+*     **%%#*#%%     
     %%**%%%**#  **++*-+*-:  .+*+=+++*+  +*#%%#*#%%    
    %%**%%%%**#*#%%%%%%*=**  ++=#%%%%%%**#*#%%%%*#%#   
   #%#*%%##%***********  *+  ** =******+ **#%%#%#*%%#  
  #%#*%%%#%%#           -*+  *+-          *%%#%%%#*%%  
  %%*#%%%#%%%          :***  *+*-          %%#%%%%*#%% 
  %%*%#%##%%%         -= *+  *  +.        %%%#%##%#*%# 
 *%#*%%#%#%%%%        :=%*+==*#+-.    #   %%%%###%#*%% 
  %%*#%#####%%  -#%:    +%%%%%*.    *%%  *%#*####%**%% 
  #%#*%##%%#%%*   #%%%%%%%% %%%%%%%%%*   #%%*%%#%#*%%% 
   %%**%%#%#%%%      .:**#%%%%%#*-::    %%%%*%#%%*#%#  
    %%**%#%#%%%%                       +%%%%+%#%*#%#   
     %%#*#%#%%%%%#        #%%+        %%%%%%+%**#%#    
      #%%**#%%##%%%       *%%      .-%%*##%%**#%%      
        %%%*#%%#%%%%%     #%%*    :%%%%%*%%**%%%       
          %%%#%#%%##%%#   #%%:  #%%###%*###%%%         
            %%%%#%%%#%%%%#=%#-#%%%%#%%##%%%#           
               %%%%%%##%%%%%%%%%%#%%%%%%%              
                 #%%%%#%%%%%%%%%##%%%%                 
                    #%%%%%%%%%%%%%%                    
                        %%%%%%%                  
EOF
#---------------------------------------------------
# Logo
#-----------------------------------------------
banner_ascii(){
    # ASCII ART (branding only)
    echo -e "${GREEN}$BANNER_ASCII${RESET}"
}
# Logging Function
log_message() {
    local level=$1
    shift
    local message="$*"
    # Ensure log file exists
    touch "$LOG_FILE" 2>/dev/null || {
        echo -e "${RED}Warning: Could not create log file $LOG_FILE (permissions?). Continuing without logging.${RESET}" >&2
        return
    }
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
}
# Enhanced Logging Function for Commands
log_command() {
    local level=$1
    local cmd=$2
    local output=$3
    local exit_code=$4
    log_message "$level" "Executing command: $cmd"
    if [[ -n "$output" ]]; then
        log_message "$level" "Command output: $output"
    fi
    log_message "$level" "Command exit code: $exit_code"
}

# ---------------------------------------------------------
# Apply Feenix ProxyChains config on script start
# ---------------------------------------------------------
apply_proxychains_config() {
    log_message "ACTION" "Applying Feenix ProxyChains configuration"

    # Remove existing config
    if [[ -f "$PROXY_ETC" ]]; then
        sudo rm -f "$PROXY_ETC"
        log_message "INFO" "Removed existing $PROXY_ETC"
    fi

    # Copy Feenix config
    if [[ -f "$PROXY_CUSTOM" ]]; then
        sudo cp "$PROXY_CUSTOM" "$PROXY_ETC"
        sudo chmod 644 "$PROXY_ETC"
        log_message "INFO" "Feenix proxychains4.conf applied"
    else
        log_message "ERROR" "Missing custom config: $PROXY_CUSTOM"
        echo -e "${RED}ERROR: Feenix proxychains4.conf not found${RESET}"
        exit 1
    fi
}


# ---------------------------------------------------------
# Restore original ProxyChains config on exit
# ---------------------------------------------------------
restore_proxychains_config() {
    log_message "ACTION" "Restoring original ProxyChains configuration"

    if [[ -f "$PROXY_ETC" ]]; then
        sudo rm -f "$PROXY_ETC"
        log_message "INFO" "Removed active proxychains4.conf"
    fi

    if [[ -f "$PROXY_BACKUP" ]]; then
        sudo cp "$PROXY_BACKUP" "$PROXY_ETC"
        sudo chmod 644 "$PROXY_ETC"
        log_message "INFO" "ProxyChains backup restored"
    else
        log_message "WARNING" "Backup config missing: $PROXY_BACKUP"
    fi
}

# Initialize Log
log_message "INFO" "Feenix Anonimizer started. Script directory: $SCRIPT_DIR"
apply_proxychains_config
trap restore_proxychains_config EXIT INT TERM
# ---------------------------------------------------------
# Function to Get Current MAC
# ---------------------------------------------------------
get_current_mac() {
    if [[ -n "$ORIGINAL_INTERFACE" ]]; then
        local mac
        mac=$(ip link show "$ORIGINAL_INTERFACE" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | head -n1)
        log_message "ACTION" "Retrieved current MAC for interface $ORIGINAL_INTERFACE: $mac"
        echo "$mac"
    else
        log_message "WARNING" "get_current_mac called without ORIGINAL_INTERFACE set"
        echo "N/A"
    fi
}
# ---------------------------------------------------------
# Utility: get plain public IP (non-Tor)
# ---------------------------------------------------------
get_public_ip_plain() {
    log_message "ACTION" "Fetching plain public IP"
    local ip cmd output exit_code
    cmd="curl -s --max-time 8 https://api.ipify.org"
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    log_command "ACTION" "$cmd" "$output" "$exit_code"
    ip="$output"
    if [[ -z "$ip" ]]; then
        log_message "WARNING" "api.ipify.org failed, falling back to ifconfig.co"
        cmd="curl -s --max-time 8 https://ifconfig.co"
        output=$(eval "$cmd" 2>&1)
        exit_code=$?
        log_command "ACTION" "$cmd" "$output" "$exit_code"
        ip="$output"
    fi
    if [[ -n "$ip" ]]; then
        log_message "INFO" "Public IP fetched: $ip"
    else
        log_message "ERROR" "Failed to fetch public IP (network/timeout issue)"
    fi
    echo "$ip"
}
# ---------------------------------------------------------
# animate_ascii_reveal
# ---------------------------------------------------------
animate_ascii_reveal() {
    local delay=0.020
    while IFS= read -r line; do
        echo -e "${GREEN}$line${RESET}"
        sleep "$delay"
    done <<< "$BANNER_ASCII"
}


# ---------------------------------------------------------
# Slow Hacker-Style Startup Animation
# ---------------------------------------------------------
start_animation() {
    log_message "ACTION" "Starting animation sequence"
    frames=(
        "[=---------] Initializing core modules..."
        "[===-------] Loading anonymity engine..."
        "[=====-----] Preparing network interfaces..."
        "[=======---] Activating stealth mode..."
        "[========= ] Establishing secure layers..."
        "[==========] Feenix is now operational."
    )
    for frame in "${frames[@]}"; do
        echo -ne "${GREEN}\r$frame${RESET}"
        sleep 0.8
    done
    echo -e "\n"
    animate_ascii_reveal
    log_message "INFO" "Animation completed"
}
# ---------------------------------------------------------
# Hacker Loading Bar
# ---------------------------------------------------------
loading_bar() {
    log_message "ACTION" "Running loading bar"
    echo -e "${CYAN}Booting Feenix Anonymizer Engine...${RESET}"
    echo ""
    for i in {1..40}; do
        echo -ne "${GREEN}#${RESET}"
        sleep 0.03
    done
    echo -e "\n${CYAN}? System Ready${RESET}"
    sleep 1
    log_message "INFO" "Loading bar completed"
}
# ---------------------------------------------------------
# Hacker Banner
# ---------------------------------------------------------
banner() {
    log_message "ACTION" "Displaying banner"
    clear
    echo -e "${CYAN}=========================================================${RESET}"
    echo -e " ${GREEN}Feenix Anonimizer 4.2v${RESET}"
    echo -e " ${CYAN}Developed by:${GREEN} Pawan Sandeepa${RESET}"
    echo -e "${CYAN}=========================================================${RESET}"
    echo ""	
}

# ---------------------------------------------------------
# Hacker Banner2
# ---------------------------------------------------------
banner2() {
    log_message "ACTION" "Displaying banner"
    clear
    echo -e "${CYAN}=========================================================${RESET}"
    echo -e " ${GREEN}Feenix Anonimizer 4.2v${RESET}"
    echo -e " ${CYAN}Developed by:${GREEN} Pawan Sandeepa${RESET}"
    echo -e "${CYAN}=========================================================${RESET}"
    echo ""
    banner_ascii
    echo ""	
}
# ---------------------------------------------------------
# Initialize Globals (Detect Interface and Original MAC)
# ---------------------------------------------------------
initialize_network() {
    log_message "ACTION" "Initializing network (detecting interface and original MAC)"
    if [[ -z "$ORIGINAL_INTERFACE" ]]; then
        local cmd output exit_code
        cmd="ip route | awk '/default/ {print \$5; exit}'"
        output=$(eval "$cmd" 2>&1)
        exit_code=$?
        log_command "ACTION" "$cmd" "$output" "$exit_code"
        ORIGINAL_INTERFACE="$output"
        if [[ -z "$ORIGINAL_INTERFACE" ]]; then
            log_message "ERROR" "Failed to identify default network interface"
            echo -e "${RED}Warning: Could not identify default network interface.${RESET}"
            return 1
        fi
        log_message "INFO" "Default interface detected: $ORIGINAL_INTERFACE"
        echo -e "${CYAN}Initializing network status for interface: $ORIGINAL_INTERFACE${RESET}"
        cmd="ip link show \"$ORIGINAL_INTERFACE\" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | head -n1"
        output=$(eval "$cmd" 2>&1)
        exit_code=$?
        log_command "ACTION" "$cmd" "$output" "$exit_code"
        ORIGINAL_MAC="$output"
        if [[ -z "$ORIGINAL_MAC" ]]; then
            log_message "ERROR" "Failed to retrieve original MAC for $ORIGINAL_INTERFACE"
            echo -e "${RED}Warning: Could not retrieve original MAC address.${RESET}"
            return 1
        fi
        log_message "INFO" "Original MAC saved: $ORIGINAL_MAC"
        echo -e "${GREEN}Original MAC detected and saved: $ORIGINAL_MAC${RESET}"
    else
        log_message "INFO" "Network already initialized (interface: $ORIGINAL_INTERFACE)"
    fi
}
# ---------------------------------------------------------
# MENU with Status Section
# ---------------------------------------------------------
menu() {
    log_message "ACTION" "Displaying main menu"
    echo ""
    echo -e "${GREEN}[1]${RESET} Change MAC Address (Required)"
    echo -e "${GREEN}[2]${RESET} Connect VPN "
    echo -e "${GREEN}[3]${RESET} Use ProxyChains "
    echo -e "${GREEN}[4]${RESET} Use Tor (Onion Routing)"
    echo -e "${GREEN}[5]${RESET} Connect to I2P (Garlic Routing)"
    echo -e "${GREEN}[99]${RESET} Reset Network (use this unless internet browsing is not working)"
    echo -e "${GREEN}[9]${RESET} Exit"
    echo ""
    # Status Section: MAC info (if changed) + Public / Exit IP info (if present)
    if [[ "$MAC_CHANGED" == true ]] || [[ -n "$CURRENT_PUBLIC_IP" ]] || [[ -n "$EXIT_NODE_IP" ]] || [[ -n "$NETWORK_REPAIRED" ]]; then
        echo -e "${CYAN}--- STATUS ---${RESET}"
        if [[ -n "$ORIGINAL_MAC" ]]; then
            CURRENT_MAC=$(get_current_mac)
            echo -e "${GREEN}Previous MAC:${RESET} $ORIGINAL_MAC"
            echo -e "${GREEN}Current MAC:${RESET} $CURRENT_MAC"
        fi
        
        if [[ "$VPN_CONNECTED" == true && -n "$VPN_COUNTRY" ]]; then
    		echo -e "${GREEN}VPN Status:${RESET} Connected via $VPN_COUNTRY"
	fi

        
        if [[ -n "$CURRENT_PUBLIC_IP" ]]; then
            echo -e "${GREEN}Current public IP:${RESET} $CURRENT_PUBLIC_IP"
        fi
        if [[ -n "$EXIT_NODE_IP" ]]; then
            echo -e "${GREEN}Exit node IP (Tor):${RESET} $EXIT_NODE_IP"
        fi
        if [[ -n "$NETWORK_REPAIRED" ]]; then
            echo -e "${GREEN}$NETWORK_REPAIRED${RESET}"
        fi
        echo -e "${CYAN}--------------${RESET}"
        echo ""
    fi
    if [[ -n "$PROXYCHAINS_ENABLED" ]]; then
    	echo -e "${GREEN}ProxyChains:${RESET} enabled"
    	echo -e "${GREEN}Application:${RESET} $PROXYCHAINS_APP"
    	echo -e "${GREEN}Proxy routing path:${RESET}"
    	echo -e "  ${CYAN}$PROXYCHAINS_PATH${RESET}"
    	echo -e "${GREEN}$PROXYCHAINS_ENABLED${RESET}"
    fi
    

    read -p " Select an option: " choice
    log_message "ACTION" "User selected cd option: $choice"
}
# ---------------------------------------------------------
# Updated MAC Change Function with Restore Option
# ---------------------------------------------------------
change_mac() {
    log_message "ACTION" "Starting MAC address change protocol"
    
        echo -e "${CYAN}==============================${RESET}"
        echo -e "${GREEN}      Mac Changing Menu        ${RESET}"
        echo -e "${CYAN}==============================${RESET}"
        echo 
    echo -e "${CYAN}Initiating MAC Address Change Protocol...${RESET}"
    echo -e "${RED}WARNING: This will temporarily disrupt your network connection.${RESET}"
    read -p "Proceed to flush network configuration? (y/N): " confirm
    if [[ $confirm != [yY] ]]; then
        log_message "INFO" "MAC change cancelled by user"
        echo -e "${RED}Operation cancelled.${RESET}"
        sleep 1
        return
    fi
    log_message "ACTION" "User confirmed MAC change; initializing network"
    # Initialize network only if not already done (first successful proceed)
    initialize_network
    if [[ -z "$ORIGINAL_INTERFACE" ]]; then
        log_message "ERROR" "Network initialization failed during MAC change"
        echo -e "${RED}Error: Network initialization failed.${RESET}"
        sleep 1
        return
    fi
    echo -e "${CYAN}Detected interface: $ORIGINAL_INTERFACE${RESET}"
    echo -e "${CYAN}Original MAC: $ORIGINAL_MAC${RESET}"
    # Flush IP addresses and bring interface down (in background for minimal disruption)
    log_message "ACTION" "Flushing IP addresses and downing interface $ORIGINAL_INTERFACE"
    local cmd output exit_code
    cmd="ip addr flush dev \"$ORIGINAL_INTERFACE\""
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    log_command "ACTION" "$cmd" "$output" "$exit_code"
    cmd="ip link set \"$ORIGINAL_INTERFACE\" down"
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    log_command "ACTION" "$cmd" "$output" "$exit_code"
    DOWN_PID=$!
    log_message "ACTION" "Interface downed in background (PID: $DOWN_PID)"
    echo -e "${CYAN}Interface downed in background (PID: $DOWN_PID). Flushing complete.${RESET}"
    sleep 2 # Brief pause to ensure down
    # Prompt for MAC change option
    echo ""
    echo -e "${GREEN}[1]${RESET} Generate Random MAC Address"
    echo -e "${GREEN}[2]${RESET} Set Custom MAC Address"
    echo -e "${GREEN}[3]${RESET} Restore Default MAC Address"
    echo ""
    read -p "Select an option: " mac_choice
    log_message "ACTION" "User selected MAC option: $mac_choice"
    local change_success=false
    case $mac_choice in
        1)
            log_message "ACTION" "Generating random MAC address using macchanger -r"
            echo -e "${CYAN}Generating random MAC address...${RESET}"
            if ! command -v macchanger >/dev/null 2>&1; then
                log_message "ERROR" "macchanger not installed"
                echo -e "${RED}macchanger not installed. Install it (e.g., sudo apt install macchanger) and retry.${RESET}"
                cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                sleep 1
                return
            fi
            cmd="macchanger -r \"$ORIGINAL_INTERFACE\""
            output=$(eval "$cmd" 2>&1)
            exit_code=$?
            log_command "ACTION" "$cmd" "$output" "$exit_code"
            if [[ $exit_code -eq 0 ]]; then
                NEW_MAC=$(get_current_mac)
                log_message "INFO" "Random MAC applied successfully: $NEW_MAC"
                echo -e "${GREEN}Random MAC applied: $NEW_MAC${RESET}"
                change_success=true
            else
                log_message "ERROR" "macchanger -r failed for $ORIGINAL_INTERFACE (check root privileges)"
                echo -e "${RED}Error: Failed to change MAC (ensure macchanger is installed and run as root).${RESET}"
                cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                sleep 1
                return
            fi
            ;;
        2)
            read -p "Enter custom MAC address (e.g., AA:BB:CC:DD:EE:FF): " custom_mac
            log_message "ACTION" "User entered custom MAC: $custom_mac"
            if [[ ! $custom_mac =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]; then
                log_message "ERROR" "Invalid custom MAC format: $custom_mac"
                echo -e "${RED}Invalid MAC format. Aborting.${RESET}"
                cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                sleep 1
                return
            fi
            echo -e "${CYAN}Applying custom MAC: $custom_mac${RESET}"
            if ! command -v macchanger >/dev/null 2>&1; then
                log_message "ERROR" "macchanger not installed for custom MAC"
                echo -e "${RED}macchanger not installed. Install it (e.g., sudo apt install macchanger) and retry.${RESET}"
                cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                sleep 1
                return
            fi
            cmd="macchanger -m \"$custom_mac\" \"$ORIGINAL_INTERFACE\""
            output=$(eval "$cmd" 2>&1)
            exit_code=$?
            log_command "ACTION" "$cmd" "$output" "$exit_code"
            if [[ $exit_code -eq 0 ]]; then
                log_message "INFO" "Custom MAC applied successfully: $custom_mac"
                echo -e "${GREEN}Custom MAC applied successfully.${RESET}"
                change_success=true
            else
                log_message "ERROR" "macchanger -m failed for $custom_mac on $ORIGINAL_INTERFACE (check root privileges)"
                echo -e "${RED}Error: Failed to change MAC (ensure macchanger is installed and run as root).${RESET}"
                cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                sleep 1
                return
            fi
            ;;
        3)
            log_message "ACTION" "Restoring default MAC address using macchanger -p"
            echo -e "${CYAN}Restoring default MAC address...${RESET}"
            if ! command -v macchanger >/dev/null 2>&1; then
                log_message "ERROR" "macchanger not installed for restore"
                echo -e "${RED}macchanger not installed. Install it (e.g., sudo apt install macchanger) and retry.${RESET}"
                cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                sleep 1
                return
            fi
            cmd="macchanger -p \"$ORIGINAL_INTERFACE\""
            output=$(eval "$cmd" 2>&1)
            exit_code=$?
            log_command "ACTION" "$cmd" "$output" "$exit_code"
            if [[ $exit_code -eq 0 ]]; then
                log_message "INFO" "Default MAC restored: $ORIGINAL_MAC"
                echo -e "${GREEN}Default MAC restored: $ORIGINAL_MAC${RESET}"
                change_success=true
            else
                log_message "ERROR" "macchanger -p failed for $ORIGINAL_INTERFACE (check root privileges)"
                echo -e "${RED}Error: Failed to restore MAC (ensure macchanger is installed and run as root).${RESET}"
                cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                sleep 1
                return
            fi
            ;;
        *)
            log_message "WARNING" "Invalid MAC option selected: $mac_choice"
            echo -e "${RED}Invalid option. Aborting.${RESET}"
            cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
            output=$(eval "$cmd" 2>&1)
            exit_code=$?
            log_command "ACTION" "$cmd" "$output" "$exit_code"
            sleep 1
            return
            ;;
    esac
    # If success, set the changed flag
    if [[ "$change_success" == true ]]; then
        MAC_CHANGED=true
        log_message "INFO" "MAC change completed successfully"
    fi
    # Bring interface back up
    log_message "ACTION" "Reactivating interface $ORIGINAL_INTERFACE"
    cmd="ip link set \"$ORIGINAL_INTERFACE\" up"
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    log_command "ACTION" "$cmd" "$output" "$exit_code"
    wait $DOWN_PID 2>/dev/null || true # Wait for background down process if still running
    echo -e "${CYAN}Interface reactivated. MAC change complete.${RESET}"
    sleep 2
}

# Define VPN credentials
username="vpnbook"
password="pvgz9pq"

# Define path to vpn.creds file (change this as per your actual location)
creds_path="$(pwd)/vpn.creds"  # Using the current script's directory

# Create vpn.creds file and set permissions
create_creds_file() {
    echo "Creating vpn.creds file at $creds_path..."
    printf "%s\n%s\n" "$username" "$password" > "$creds_path"
    chmod 600 "$creds_path"
}

# Create VPN .ovpn file for Germany
create_germany_vpn_file() {
    echo "Creating vpn.ovpn for Germany..."
    cat > vpn.ovpn <<EOL
client
dev tun1
proto tcp
remote 51.75.145.20 443
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass $creds_path
verb 3
cipher AES-256-GCM
auth SHA256
data-ciphers AES-256-GCM:AES-128-GCM
fast-io
pull
route-delay 2
redirect-gateway
<ca>
-----BEGIN CERTIFICATE-----
MIIDSzCCAjOgAwIBAgIUJdJ6+6lTiYZBvpl2P40Lgx3BeHowDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAwwLdnBuYm9vay5jb20wHhcNMjMwMjIwMTk0NTM1WhcNMzMw
MjE3MTk0NTM1WjAWMRQwEgYDVQQDDAt2cG5ib29rLmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMcVK+hYl6Wl57YxXIVy7Jlgglj42LaC2sUWK3ls
aRcKQfs/ridG6+9dSP1ziCrZ1f5pOLz34gMYXChhUOc/x9rSIRGHao4gHeXmEoGs
twjxA+kRBSv5xqeUgaTKAhdwiV5SvBE8EViWe3rlHLoUbWBQ7Kky/L4cg7u+ma1V
31PgOPhWY3RqZJLBMu3PHCctaaHQyoPLDNDyCz7Zb2Wos+tjIb3YP5GTfkZlnJsN
va0HdSGEyerTQL5fqW2V6IZ4t2Np2kVnJcfEWgJF0Kw1nqoPfKjxM44bR+K1EGGW
ir1rs/RFPg8yFVxd4ZHpqoCo2lXZjc6oP1cwtIswIHb6EbsCAwEAAaOBkDCBjTAd
BgNVHQ4EFgQULgM8Z91cLOSHl6EDF8jalx3piqQwUQYDVR0jBEowSIAULgM8Z91c
LOSHl6EDF8jalx3piqShGqQYMBYxFDASBgNVBAMMC3ZwbmJvb2suY29tghQl0nr7
qVOJhkG+mXY/jQuDHcF4ejAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjANBgkq
hkiG9w0BAQsFAAOCAQEAT5hsP+dz11oREADNMlTEehXWfoI0aBws5c8noDHoVgnc
BXuI4BREP3k6OsOXedHrAPA4dJXG2e5h33Ljqr5jYbm7TjUVf1yT/r3TDKIJMeJ4
+KFs7tmXy0ejLFORbk8v0wAYMQWM9ealEGePQVjOhJJysEhJfA4u5zdGmJDYkCr+
3cTiig/a53JqpwjjYFVHYPSJkC/nTz6tQOw9crDlZ3j+LLWln0Cy/bdj9oqurnrc
xUtl3+PWM9D1HoBpdGduvQJ4HXfss6OrajukKfDsbDS4njD933vzRd4E36GjOI8Q
1VKIe7kamttHV5HCsoeSYLjdxbXBAY2E0ZhQzpZB7g==
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIDYDCCAkigAwIBAgIQP/z/mAlVNddzohzjQghcqzANBgkqhkiG9w0BAQsFADAW
MRQwEgYDVQQDDAt2cG5ib29rLmNvbTAeFw0yMzAyMjAyMzMwNDlaFw0zMzAyMTcy
MzMwNDlaMB0xGzAZBgNVBAMMEmNsaWVudC52cG5ib29rLmNvbTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBANPiNyyYH6yLXss6AeHLzJ6/9JfUzVAs7ttq
8OWJRkBjKuEPW3MUVjpMgptm6+zJohM4IdSo/ES6H81sLK4AWiUUOzeOt8xAzgib
NrLss5px0D0Pm+uXH8hGOle386JH5oyOQ6ub2O3ro0TeTF4rg43TF1oOz2AVS/gc
sB3d6AG73otZ4C6/wabiGz4rFO8xl4S4PBKX73Eb7cdSoACc8AIrqcR+PEDHOZYt
1qp4lM87+5ADEXelpe9vLTaoXonIuZElqA9rwFi/KQmPCHsl7eEnmSo1iOg0y3iP
0CRHzv8FkvhhpB9Z3i3TUxq8XvnLtEQ38eD5Dw20WMYPmPShtXMCAwEAAaOBojCB
nzAJBgNVHRMEAjAAMB0GA1UdDgQWBBQKO5Ub8pRCA8iTdRIxUIeMpNX2vzBRBgNV
HSMESjBIgBQuAzxn3Vws5IeXoQMXyNqXHemKpKEapBgwFjEUMBIGA1UEAwwLdnBu
Ym9vay5jb22CFCXSevupU4mGQb6Zdj+NC4MdwXh6MBMGA1UdJQQMMAoGCCsGAQUF
BwMCMAsGA1UdDwQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAQEAel1YOAWHWFLH3N41
SCIdQNbkQ18UFBbtZz4bzV6VeCWHNzPtWQ6UIeADpcBp0mngS09qJCQ8PwOBMvFw
MizhDz2Ipz817XtLJuEMQ3Io51LRxPP394mlw46e8KFOh06QI8jnC/QlBH19PI+M
OeQ3Gx6uYK41HHmyu/Z7dUE4c4s2iiHA7UgD98dkrU0rGAv1R/d2xRXqEm4PrwDj
MlC1TY8LrIJd6Ipt00uUfHVAzhX3NKR528azYH3bud5NV+KEiQZSyirUyoMbMQeO
UXh+GEDX5GBPElzQmPOsLete/PMH9Ayg6Gh/sccqwgH7BxjqcVLKXg2S4jL5BUPd
kI3/sg==
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDT4jcsmB+si17L
OgHhy8yev/SX1M1QLO7bavDliUZAYyrhD1tzFFY6TIKbZuvsyaITOCHUqPxEuh/N
bCyuAFolFDs3jrfMQM4Imzay7LOacdA9D5vrlx/IRjpXt/OiR+aMjkOrm9jt66NE
3kxeK4ON0xdaDs9gFUv4HLAd3egBu96LWeAuv8Gm4hs+KxTvMZeEuDwSl+9xG+3H
UqAAnPACK6nEfjxAxzmWLdaqeJTPO/uQAxF3paXvby02qF6JyLmRJagPa8BYvykJ
jwh7Je3hJ5kqNYjoNMt4j9AkR87/BZL4YaQfWd4t01MavF75y7REN/Hg+Q8NtFjG
D5j0obVzAgMBAAECggEAAV/BLdfatLq+paC9rGIu9ISYKHfn0PJJpkCeSU7HltlN
yOHZnPhvyrb+TdWwB/wSwf8mMQPbhvKSDDn8XDCCZSUpcSXKyVdOPr4K78QbMhA0
4oB8aV20hg72h+UYfl/q/dRaWf2LvZc+ms66Pg4YL05EI4BfFedtc7Fz7u2meIRl
Wm0b7/QQ10wrR1I7PonZzgnU9diB1cKxptJ06AfJmCGobymjq/A1JsAr/NFnJlmu
yq3n5tcRpfc8K+XsfnpwDQJo3kKwLGIoBmUkGEcHgQhVwOL5+P+3pTYr1bt4cAUp
FxbExqcxW0es//g3x2Z80icUpa4/OvSTAa0XF3J4UQKBgQDv4E/3/r5lULYIksNC
zO1yRp7awv41ZAUpDSglNtWsehnhhUsiVE/Ezmyz4E0qjsW2+EUxUZ990T4ZVK4b
9cEhB/TDBc6PBPd498aIGiiqznWXMdsU2o6xrvkQeWdmXoVjvWTcRWlfAQ+PQBOJ
tJ3wR7ZoHgu0P/yzIzn0eQ+BiQKBgQDiIDgRtlQBw8tZc66OzxWOuJh6M5xUF5zY
S0SLXFWlKVkfGACaerHUlFwZKID39BBifgXO1VOQ6AzalDd2vaIU9CHo2bFpTY7S
EkkcIt9Gpl5o1sjEyJChXBIz+s48XBMXlqFN7AdhX/H6R43g8eS/YlzqSBxkUcAa
V3tt8n+sGwKBgD+aSXnnKNKyWOHjEDUJIzh2sy4sH71GXPvqiid756II6g3bCvX6
RwBW/4meQrezDYebQrV2AAUbUwziYBv3yJKainKfeop/daK0iAaUcQ4BGjrRtFZO
MSG51D5jAmCpVVMB59lj6jGPlXGVOtj7dBk+2oW22cGcacOR5o8E/nCJAoGBALVP
KCXrj8gqea4rt1cCbEKXeIrjPwGePUCgeUFUs8dONAteb31ty5CrtHznoSEvLMQM
UBPbsLmLlmLcXOx0eLVcWqQdiMbqTQ3bY4uP2n8HfsOJFEnUl0MKU/4hp6N2IEjV
mlikW/aTu632Gai3y7Y45E9lqn41nlaAtpMd0YjpAoGBAL8VimbhI7FK7X1vaxXy
tnqLuYddL+hsxXXfcIVNjLVat3L2WN0YKZtbzWD8TW8hbbtnuS8F8REg7YvYjkZJ
t8VO6ZmI7I++borJBNmbWS4gEk85DYnaLI9iw4oF2+Dr0LKKAaUL+Pq67wmvufOn
hTobb/WAAcA75GKmU4jn5Ln2
-----END PRIVATE KEY-----
</key>
EOL
}

# Create VPN .ovpn file for Canada
create_caneda_vpn_file() {
    echo "Creating vpn.ovpn for Canada..."
    cat > vpn.ovpn <<EOL
client
dev tun1
proto tcp
remote 144.217.253.149 443
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass $creds_path
verb 3
cipher AES-256-GCM
auth SHA256
data-ciphers AES-256-GCM:AES-128-GCM
fast-io
pull
route-delay 2
redirect-gateway
<ca>
-----BEGIN CERTIFICATE-----
MIIDSzCCAjOgAwIBAgIUJdJ6+6lTiYZBvpl2P40Lgx3BeHowDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAwwLdnBuYm9vay5jb20wHhcNMjMwMjIwMTk0NTM1WhcNMzMw
MjE3MTk0NTM1WjAWMRQwEgYDVQQDDAt2cG5ib29rLmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMcVK+hYl6Wl57YxXIVy7Jlgglj42LaC2sUWK3ls
aRcKQfs/ridG6+9dSP1ziCrZ1f5pOLz34gMYXChhUOc/x9rSIRGHao4gHeXmEoGs
twjxA+kRBSv5xqeUgaTKAhdwiV5SvBE8EViWe3rlHLoUbWBQ7Kky/L4cg7u+ma1V
31PgOPhWY3RqZJLBMu3PHCctaaHQyoPLDNDyCz7Zb2Wos+tjIb3YP5GTfkZlnJsN
va0HdSGEyerTQL5fqW2V6IZ4t2Np2kVnJcfEWgJF0Kw1nqoPfKjxM44bR+K1EGGW
ir1rs/RFPg8yFVxd4ZHpqoCo2lXZjc6oP1cwtIswIHb6EbsCAwEAAaOBkDCBjTAd
BgNVHQ4EFgQULgM8Z91cLOSHl6EDF8jalx3piqQwUQYDVR0jBEowSIAULgM8Z91c
LOSHl6EDF8jalx3piqShGqQYMBYxFDASBgNVBAMMC3ZwbmJvb2suY29tghQl0nr7
qVOJhkG+mXY/jQuDHcF4ejAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjANBgkq
hkiG9w0BAQsFAAOCAQEAT5hsP+dz11oREADNMlTEehXWfoI0aBws5c8noDHoVgnc
BXuI4BREP3k6OsOXedHrAPA4dJXG2e5h33Ljqr5jYbm7TjUVf1yT/r3TDKIJMeJ4
+KFs7tmXy0ejLFORbk8v0wAYMQWM9ealEGePQVjOhJJysEhJfA4u5zdGmJDYkCr+
3cTiig/a53JqpwjjYFVHYPSJkC/nTz6tQOw9crDlZ3j+LLWln0Cy/bdj9oqurnrc
xUtl3+PWM9D1HoBpdGduvQJ4HXfss6OrajukKfDsbDS4njD933vzRd4E36GjOI8Q
1VKIe7kamttHV5HCsoeSYLjdxbXBAY2E0ZhQzpZB7g==
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
MIIDYDCCAkigAwIBAgIQP/z/mAlVNddzohzjQghcqzANBgkqhkiG9w0BAQsFADAW
MRQwEgYDVQQDDAt2cG5ib29rLmNvbTAeFw0yMzAyMjAyMzMwNDlaFw0zMzAyMTcy
MzMwNDlaMB0xGzAZBgNVBAMMEmNsaWVudC52cG5ib29rLmNvbTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBANPiNyyYH6yLXss6AeHLzJ6/9JfUzVAs7ttq
8OWJRkBjKuEPW3MUVjpMgptm6+zJohM4IdSo/ES6H81sLK4AWiUUOzeOt8xAzgib
NrLss5px0D0Pm+uXH8hGOle386JH5oyOQ6ub2O3ro0TeTF4rg43TF1oOz2AVS/gc
sB3d6AG73otZ4C6/wabiGz4rFO8xl4S4PBKX73Eb7cdSoACc8AIrqcR+PEDHOZYt
1qp4lM87+5ADEXelpe9vLTaoXonIuZElqA9rwFi/KQmPCHsl7eEnmSo1iOg0y3iP
0CRHzv8FkvhhpB9Z3i3TUxq8XvnLtEQ38eD5Dw20WMYPmPShtXMCAwEAAaOBojCB
nzAJBgNVHRMEAjAAMB0GA1UdDgQWBBQKO5Ub8pRCA8iTdRIxUIeMpNX2vzBRBgNV
HSMESjBIgBQuAzxn3Vws5IeXoQMXyNqXHemKpKEapBgwFjEUMBIGA1UEAwwLdnBu
Ym9vay5jb22CFCXSevupU4mGQb6Zdj+NC4MdwXh6MBMGA1UdJQQMMAoGCCsGAQUF
BwMCMAsGA1UdDwQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAQEAel1YOAWHWFLH3N41
SCIdQNbkQ18UFBbtZz4bzV6VeCWHNzPtWQ6UIeADpcBp0mngS09qJCQ8PwOBMvFw
MizhDz2Ipz817XtLJuEMQ3Io51LRxPP394mlw46e8KFOh06QI8jnC/QlBH19PI+M
OeQ3Gx6uYK41HHmyu/Z7dUE4c4s2iiHA7UgD98dkrU0rGAv1R/d2xRXqEm4PrwDj
MlC1TY8LrIJd6Ipt00uUfHVAzhX3NKR528azYH3bud5NV+KEiQZSyirUyoMbMQeO
UXh+GEDX5GBPElzQmPOsLete/PMH9Ayg6Gh/sccqwgH7BxjqcVLKXg2S4jL5BUPd
kI3/sg==
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDT4jcsmB+si17L
OgHhy8yev/SX1M1QLO7bavDliUZAYyrhD1tzFFY6TIKbZuvsyaITOCHUqPxEuh/N
bCyuAFolFDs3jrfMQM4Imzay7LOacdA9D5vrlx/IRjpXt/OiR+aMjkOrm9jt66NE
3kxeK4ON0xdaDs9gFUv4HLAd3egBu96LWeAuv8Gm4hs+KxTvMZeEuDwSl+9xG+3H
UqAAnPACK6nEfjxAxzmWLdaqeJTPO/uQAxF3paXvby02qF6JyLmRJagPa8BYvykJ
jwh7Je3hJ5kqNYjoNMt4j9AkR87/BZL4YaQfWd4t01MavF75y7REN/Hg+Q8NtFjG
D5j0obVzAgMBAAECggEAAV/BLdfatLq+paC9rGIu9ISYKHfn0PJJpkCeSU7HltlN
yOHZnPhvyrb+TdWwB/wSwf8mMQPbhvKSDDn8XDCCZSUpcSXKyVdOPr4K78QbMhA0
4oB8aV20hg72h+UYfl/q/dRaWf2LvZc+ms66Pg4YL05EI4BfFedtc7Fz7u2meIRl
Wm0b7/QQ10wrR1I7PonZzgnU9diB1cKxptJ06AfJmCGobymjq/A1JsAr/NFnJlmu
yq3n5tcRpfc8K+XsfnpwDQJo3kKwLGIoBmUkGEcHgQhVwOL5+P+3pTYr1bt4cAUp
FxbExqcxW0es//g3x2Z80icUpa4/OvSTAa0XF3J4UQKBgQDv4E/3/r5lULYIksNC
zO1yRp7awv41ZAUpDSglNtWsehnhhUsiVE/Ezmyz4E0qjsW2+EUxUZ990T4ZVK4b
9cEhB/TDBc6PBPd498aIGiiqznWXMdsU2o6xrvkQeWdmXoVjvWTcRWlfAQ+PQBOJ
tJ3wR7ZoHgu0P/yzIzn0eQ+BiQKBgQDiIDgRtlQBw8tZc66OzxWOuJh6M5xUF5zY
S0SLXFWlKVkfGACaerHUlFwZKID39BBifgXO1VOQ6AzalDd2vaIU9CHo2bFpTY7S
EkkcIt9Gpl5o1sjEyJChXBIz+s48XBMXlqFN7AdhX/H6R43g8eS/YlzqSBxkUcAa
V3tt8n+sGwKBgD+aSXnnKNKyWOHjEDUJIzh2sy4sH71GXPvqiid756II6g3bCvX6
RwBW/4meQrezDYebQrV2AAUbUwziYBv3yJKainKfeop/daK0iAaUcQ4BGjrRtFZO
MSG51D5jAmCpVVMB59lj6jGPlXGVOtj7dBk+2oW22cGcacOR5o8E/nCJAoGBALVP
KCXrj8gqea4rt1cCbEKXeIrjPwGePUCgeUFUs8dONAteb31ty5CrtHznoSEvLMQM
UBPbsLmLlmLcXOx0eLVcWqQdiMbqTQ3bY4uP2n8HfsOJFEnUl0MKU/4hp6N2IEjV
mlikW/aTu632Gai3y7Y45E9lqn41nlaAtpMd0YjpAoGBAL8VimbhI7FK7X1vaxXy
tnqLuYddL+hsxXXfcIVNjLVat3L2WN0YKZtbzWD8TW8hbbtnuS8F8REg7YvYjkZJ
t8VO6ZmI7I++borJBNmbWS4gEk85DYnaLI9iw4oF2+Dr0LKKAaUL+Pq67wmvufOn
hTobb/WAAcA75GKmU4jn5Ln2
-----END PRIVATE KEY-----
</key>
EOL
}

# Function to connect using OpenVPN
connect_vpn() {
    local country="$1"

    echo "Connecting to VPN via $country..."

    sudo openvpn \
        --config vpn.ovpn \
        --daemon \
        --log vpn.log \
        --writepid vpn.pid

    echo "Waiting for VPN tunnel..."

    while true; do
        if grep -q "Initialization Sequence Completed" vpn.log; then
            break
        fi
        sleep 1
    done

    echo "VPN connected successfully."

    ip a show tun1 >/dev/null 2>&1 || {
        echo "ERROR: tun1 interface not found"
        return 1
    }

    #  UPDATE STATUS VARIABLES
    VPN_CONNECTED=true
    VPN_COUNTRY="$country"

    CURRENT_PUBLIC_IP=$(get_public_ip_plain)

    log_message "INFO" "VPN connected via $country | IP: $CURRENT_PUBLIC_IP"

    echo "VPN Public IP: $CURRENT_PUBLIC_IP"
}

# Function to disconnect VPN
disconnect_vpn() {
    echo "Disconnecting VPN..."

    if [ -f vpn.pid ] && [ -s vpn.pid ]; then
        sudo kill "$(cat vpn.pid)" 2>/dev/null
        rm -f vpn.pid
    else
        sudo pkill -f "openvpn.*vpn.ovpn" 2>/dev/null
    fi

    rm -f vpn.creds vpn.ovpn vpn.log

    #  RESET STATUS VARIABLES
    VPN_CONNECTED=false
    VPN_COUNTRY=""
    CURRENT_PUBLIC_IP=""

    log_message "INFO" "VPN disconnected"

    echo "VPN disconnected."
}

# ---------------------------------------------------------
# Placeholder Functions (LEGAL SAFE)
# ---------------------------------------------------------
vpn_connect() {
    log_message "ACTION" "VPN menu opened"

        echo -e "${CYAN}==============================${RESET}"
        echo -e "${GREEN}        VPN Menu              ${RESET}"
        echo -e "${CYAN}==============================${RESET}"
        echo ""
        echo -e "${GREEN}[1]${RESET} Connect via Germany"
        echo -e "${GREEN}[2]${RESET} Connect via Canada"
        echo -e "${GREEN}[3]${RESET} Disconnect VPN"
        echo -e "${GREEN}[4]${RESET} Exit to Main Menu"
        echo ""

        read -p "Option: " option
        log_message "ACTION" "VPN menu option selected: $option"

        case $option in
            1)
                create_creds_file
                create_germany_vpn_file
                connect_vpn "Germany"
                sleep 2
                ;;
            2)
                create_creds_file
                create_caneda_vpn_file
                connect_vpn "Canada"
                sleep 2
                ;;
            3)
                disconnect_vpn
                sleep 2
                ;;
            4)
                log_message "INFO" "Exiting VPN menu to main menu"
                return
                ;;
            *)
                echo -e "${RED}Invalid option. Try again.${RESET}"
                sleep 1
                ;;
        esac
    
}


proxychains_enable() {
    log_message "ACTION" "ProxyChains menu opened"

        echo -e "${CYAN}==============================${RESET}"
        echo -e "${GREEN}      ProxyChains Menu        ${RESET}"
        echo -e "${CYAN}==============================${RESET}"
        echo ""
        echo -e "${GREEN}[1]${RESET} Use Browser with ProxyChains"
        echo -e "${GREEN}[2]${RESET} Use Terminal with ProxyChains"
        echo -e "${GREEN}[3]${RESET} Exit to Main Menu"
        echo ""

        read -p "Select an option: " pc_choice
        log_message "ACTION" "User selected ProxyChains option: $pc_choice"

        case $pc_choice in
		1)
		    log_message "ACTION" "ProxyChains browser option selected"
		    echo -e "${CYAN}Launching Firefox with ProxyChains (non-root)...${RESET}"

		    if ! command -v proxychains >/dev/null 2>&1; then
			echo -e "${RED}proxychains not installed.${RESET}"
			sleep 2
			continue
		    fi

		    if ! command -v firefox >/dev/null 2>&1; then
			echo -e "${RED}Firefox not installed.${RESET}"
			sleep 2
			continue
		    fi

		    REAL_USER="${SUDO_USER:-$USER}"
		    USER_HOME=$(eval echo "~$REAL_USER")

		    PROXY_LOG="/tmp/proxychains_firefox.log"
		    : > "$PROXY_LOG"   # clear old log

		    log_message "INFO" "Launching Firefox via ProxyChains as $REAL_USER"

		    sudo -u "$REAL_USER" \
			DISPLAY="$DISPLAY" \
			XAUTHORITY="$USER_HOME/.Xauthority" \
			proxychains firefox \
			>"$PROXY_LOG" 2>&1 &

		    sleep 4   # allow proxychains to print route

		    # -------------------------------
		    # Extract routing IP path
		    # -------------------------------
		    ROUTE_IPS=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$PROXY_LOG" | tr '\n' ' ')

		    if [[ -n "$ROUTE_IPS" ]]; then
			#PROXYCHAINS_PATH="$ROUTE_IPS"
			PROXYCHAINS_PATH="routing via proxy chains"
		    else
			PROXYCHAINS_PATH="Routing path not detected yet"
		    fi

		    PROXYCHAINS_ENABLED="ProxyChains enabled — Firefox is opened"
		    PROXYCHAINS_APP="Firefox"

		    log_message "INFO" "ProxyChains path: $PROXYCHAINS_PATH"

		    # Return directly to main menu
		    break
		    ;;


            	2)
		   
		    log_message "ACTION" "ProxyChains terminal option selected"
		    echo -e "${CYAN}Launching ProxyChains-enabled terminal (Kali)...${RESET}"

		    if ! command -v proxychains >/dev/null 2>&1; then
			echo -e "${RED}proxychains not installed.${RESET}"
			sleep 2
			continue
		    fi

		    if ! command -v exo-open >/dev/null 2>&1; then
			echo -e "${RED}exo-open not found (XFCE required).${RESET}"
			sleep 2
			continue
		    fi

		    REAL_USER="${SUDO_USER:-$USER}"
		    USER_HOME=$(eval echo "~$REAL_USER")

		    log_message "INFO" "Launching proxychains bash via exo-open as $REAL_USER"

		    # -------------------------------------------------
		    # 1) Open ProxyChains-enabled terminal (CORRECT)
		    # -------------------------------------------------
		    sudo -u "$REAL_USER" \
			DISPLAY="$DISPLAY" \
			XAUTHORITY="$USER_HOME/.Xauthority" \
			exo-open --launch TerminalEmulator proxychains bash &

		    # -------------------------------------------------
		    # 2) Detect ProxyChains routing path (reliable)
		    # -------------------------------------------------
		    PROXY_LOG="/tmp/proxychains_path_test.log"
		    : > "$PROXY_LOG"

		    proxychains curl -I https://api.ipify.org \
			>"$PROXY_LOG" 2>&1

		    ROUTE_IPS=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$PROXY_LOG" | tr '\n' ' ')

		    if [[ -n "$ROUTE_IPS" ]]; then
			PROXYCHAINS_PATH="$ROUTE_IPS"
		    else
			PROXYCHAINS_PATH="Routing path not detected (check proxychains.conf)"
		    fi

		    PROXYCHAINS_ENABLED="ProxyChains enabled — Terminal is opened"
		    PROXYCHAINS_APP="Terminal"

		    log_message "INFO" "ProxyChains terminal routing path: $PROXYCHAINS_PATH"

		    # Return to main menu immediately
		    break
		    ;;

            3)
                log_message "INFO" "Exiting ProxyChains menu"
                break
                ;;

            *)
                echo -e "${RED}Invalid option!${RESET}"
                sleep 1
                ;;
        esac
}
# ---------------------------------------------------------
# I2P Check
# ---------------------------------------------------------
is_i2p_installed() {
    dpkg -l | grep -qw i2p
}


# ---------------------------------------------------------
# I2P Garlic Storm Animation (Hacker Style)
# ---------------------------------------------------------

spinner() {
    log_message "ACTION" "Starting I2P garlic text animation"

    frames=("CONNECTING" "CONNECTING." "CONNECTING.." "CONNECTING...")  # simple text spinner
    duration=6    # total animation duration in seconds
    interval=0.5  # speed per frame
    end_time=$((SECONDS + duration))

    echo -e "${CYAN}🧄 Garlic Routing Loader${RESET}"
    tput civis  # hide cursor

    while [ $SECONDS -lt $end_time ]; do
        for f in "${frames[@]}"; do
            echo -ne "\r$f"
            sleep $interval
        done
    done

    tput cnorm  # show cursor
    echo -e "\r${GREEN}[✓] Garlic Routing connected!${RESET}"
}

# ---------------------------------------------------------
# I2P Install (Kali-safe, EXACT guide)
# ---------------------------------------------------------
install_i2p() {
    log_message "ACTION" "Installing I2P (Kali-safe method)"

    echo -e "${CYAN}[+] Installing I2P prerequisites...${RESET}"
    sudo apt update
    sudo apt install -y apt-transport-https lsb-release curl gnupg

    echo -e "${CYAN}[+] Adding I2P repository (Kali compatible)...${RESET}"
    echo "deb [signed-by=/usr/share/keyrings/i2p-archive-keyring.gpg] https://deb.i2p.net/ $(dpkg --status tzdata | grep Provides | cut -f2 -d'-') main" \
    | sudo tee /etc/apt/sources.list.d/i2p.list

    echo -e "${CYAN}[+] Downloading I2P signing key...${RESET}"
    curl -o i2p-archive-keyring.gpg https://geti2p.net/_static/i2p-archive-keyring.gpg

    echo -e "${CYAN}[+] Verifying key fingerprint...${RESET}"
    gpg --keyid-format long --import --import-options show-only --with-fingerprint i2p-archive-keyring.gpg

    echo -e "${CYAN}[+] Installing keyring...${RESET}"
    sudo cp i2p-archive-keyring.gpg /usr/share/keyrings/

    echo -e "${CYAN}[+] Installing I2P packages...${RESET}"
    sudo apt update
    sudo apt install -y i2p i2p-keyring

    echo -e "${CYAN}[+] Running dpkg-reconfigure i2p (recommended)...${RESET}"
    sudo dpkg-reconfigure i2p

    log_message "INFO" "I2P installation completed"
}

i2p_connect() {
    log_message "ACTION" "I2P selected from main menu"
    
        #echo -e "${CYAN}==============================${RESET}"
        #echo -e "${GREEN}      i2p Menu        ${RESET}"
        #echo -e "${CYAN}==============================${RESET}"
        echo 

    # -------------------------------------------------
    # CHECK / INSTALL I2P
    # -------------------------------------------------
    if ! is_i2p_installed; then
        echo -e "${RED}[!] I2P is not installed.${RESET}"
        read -p "Install I2P now? (y/N): " install_confirm

        if [[ $install_confirm =~ ^[yY]$ ]]; then
            install_i2p
        else
            echo -e "${RED}I2P installation skipped.${RESET}"
            sleep 2
            return
        fi
    fi

    # -------------------------------------------------
    # I2P SUB MENU
    # -------------------------------------------------
    while true; do
        #clear
        echo -e "${CYAN}==============================${RESET}"
        echo -e "${GREEN}   I2P (Garlic Routing) Menu   ${RESET}"
        echo -e "${CYAN}==============================${RESET}"
        echo ""
        echo -e "${GREEN}[1]${RESET} Start I2P & Open Router Console"
        echo -e "${GREEN}[2]${RESET} Stop I2P"
        echo -e "${GREEN}[3]${RESET} Back to Main Menu"
        echo ""

        read -p "Select an option: " i2p_choice
        log_message "ACTION" "User selected I2P option: $i2p_choice"

        case $i2p_choice in
            1)
                #i2p_garlic_storm
                spinner
                echo -e "${CYAN}[+] Starting I2P service...${RESET}"
                sudo systemctl start i2p

                sleep 3

                echo -e "${CYAN}[+] Opening I2P Router Console...${RESET}"

                REAL_USER="${SUDO_USER:-$USER}"
                USER_HOME=$(eval echo "~$REAL_USER")

                sudo -u "$REAL_USER" \
                    DISPLAY="$DISPLAY" \
                    XAUTHORITY="$USER_HOME/.Xauthority" \
                    /usr/lib/firefox-esr/firefox-esr http://127.0.0.1:7657 &

                NETWORK_REPAIRED=$'I2P Router Console opened (Garlic routing active)\n\nUse manual proxy in Firefox:\nSettings > Network Settings > Manual proxy configuration\nHTTP  Proxy : 127.0.0.1  Port 4444\nHTTPS Proxy: 127.0.0.1  Port 4445\nSOCKS Host : 127.0.0.1  Port 4447'
                log_message "INFO" "$NETWORK_REPAIRED"

                sleep 2
                ;;

            2)
                echo -e "${CYAN}[+] Stopping I2P service...${RESET}"
                sudo systemctl stop i2p
                NETWORK_REPAIRED="I2P service stopped"
                log_message "INFO" "I2P stopped"
                sleep 2
                ;;

            3)
                log_message "INFO" "Exiting I2P menu"
                return
                ;;

            *)
                echo -e "${RED}Invalid option!${RESET}"
                sleep 1
                ;;
        esac
    done
}


# ---------------------------------------------------------
# Tor Enable Function (Full Implementation per request)
# ---------------------------------------------------------
tor_enable() {
    log_message "ACTION" "Tor enable selected"
    echo -e "${CYAN}Tor (Onion Routing) - Selected${RESET}"
        echo -e "${CYAN}==============================${RESET}"
        echo -e "${GREEN}      TOR Menu        ${RESET}"
        echo -e "${CYAN}==============================${RESET}"
        echo 
    # 1) store current public IP
    #echo -e "${CYAN}Detecting your current public IP (non-Tor)...${RESET}"
    #CURRENT_PUBLIC_IP=$(get_public_ip_plain)
    #if [[ -z "$CURRENT_PUBLIC_IP" ]]; then
    #    log_message "WARNING" "Could not determine current public IP"
    #    echo -e "${RED}Could not determine current public IP (network issue?).${RESET}"
    #else
    #    echo -e "${GREEN}Current public IP saved: ${CURRENT_PUBLIC_IP}${RESET}"
    #fi
    echo ""
    echo -e "${GREEN}[1]${RESET} Use Tor Browser (GUI) with Tor routing"
    echo -e "${GREEN}[2]${RESET} Use Terminal with Tor routing (torsocks / system tor)"
    echo -e "${GREEN}[3]${RESET} Back"
    echo ""
    read -p "Select an option: " tor_choice
    log_message "ACTION" "User selected Tor option: $tor_choice"
    case $tor_choice in
        1)
        
	    log_message "ACTION" "Launching Tor Browser (GUI)"

	    echo -e "${CYAN}Launching Tor Browser safely as normal user...${RESET}"

	    if ! command -v torbrowser-launcher >/dev/null 2>&1; then
		echo -e "${RED}torbrowser-launcher is not installed.${RESET}"
		sleep 2
		return
	    fi

	    REAL_USER="${SUDO_USER:-$USER}"
	    USER_HOME=$(eval echo "~$REAL_USER")

	    sudo -u "$REAL_USER" \
		DISPLAY="$DISPLAY" \
		XAUTHORITY="$USER_HOME/.Xauthority" \
		torbrowser-launcher %u \
		>/tmp/torbrowser.log 2>&1 &

	    # SET ONLY THIS STATUS
	    NETWORK_REPAIRED="Tor Browser is Opened. Use it"

	    log_message "INFO" "Tor Browser launched (GUI mode)"

	    # VERY IMPORTANT
	    return
	    ;;


        2)
            log_message "ACTION" "Setting up system Tor (terminal routing)"
            
            # 2) store current public IP
            echo -e "${CYAN}Detecting your current public IP (non-Tor)...${RESET}"
	    CURRENT_PUBLIC_IP=$(get_public_ip_plain)
            # Option 2: Terminal with tor routing
            echo -e "${CYAN}Preparing system Tor (terminal routing) ...${RESET}"
            # Check for sudo availability
            if ! sudo -n true >/dev/null 2>&1; then
                log_message "WARNING" "Sudo privileges required for Tor setup"
                echo -e "${RED}This operation needs sudo privileges. You will be prompted for your password.${RESET}"
            fi
            # Accept: ensure torrc contains SocksPort 9050 (or add it)
            TORRC_FILE_CANDIDATES=(/etc/tor/torrc /etc/tor/torcc)
            chosen_torrc=""
            for f in "${TORRC_FILE_CANDIDATES[@]}"; do
                if [[ -f "$f" ]]; then
                    chosen_torrc="$f"
                    break
                fi
            done
            if [[ -z "$chosen_torrc" ]]; then
                # fallback: create /etc/tor/torrc
                chosen_torrc="/etc/tor/torrc"
                log_message "ACTION" "No torrc found; creating $chosen_torrc"
                echo -e "${CYAN}No existing tor config found; will create ${chosen_torrc} (requires sudo)${RESET}"
                local cmd output exit_code
                cmd="sudo bash -c \"mkdir -p /etc/tor 2>/dev/null || true; touch ${chosen_torrc}\""
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                if [[ $exit_code -ne 0 ]]; then
                    log_message "ERROR" "Failed to create $chosen_torrc (permissions)"
                    echo -e "${RED}Failed to create ${chosen_torrc}. Check permissions.${RESET}"
                    return
                fi
                log_message "INFO" "Created $chosen_torrc"
            else
                log_message "INFO" "Using existing torrc: $chosen_torrc"
            fi
            # Check and append SocksPort 9050 if missing
            local cmd_check="sudo grep -Ei '^\s*SocksPort\s+9050\s*$' \"$chosen_torrc\""
            output=$(eval "$cmd_check" 2>&1)
            exit_code=$?
            log_command "ACTION" "$cmd_check" "$output" "$exit_code"
            if [[ $exit_code -eq 0 ]]; then
                log_message "INFO" "SocksPort 9050 already in $chosen_torrc"
                echo -e "${GREEN}SocksPort 9050 already present in ${chosen_torrc}${RESET}"
            else
                log_message "ACTION" "Adding SocksPort 9050 to $chosen_torrc"
                echo -e "${CYAN}Adding 'SocksPort 9050' to ${chosen_torrc} (requires sudo)${RESET}"
                cmd="echo \"SocksPort 9050\" | sudo tee -a \"$chosen_torrc\""
                output=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$output" "$exit_code"
                if [[ $exit_code -ne 0 ]]; then
                    log_message "ERROR" "Failed to append to $chosen_torrc"
                    echo -e "${RED}Failed to write to ${chosen_torrc}.${RESET}"
                    return
                fi
                log_message "INFO" "SocksPort 9050 appended to $chosen_torrc"
                echo -e "${GREEN}Line appended.${RESET}"
            fi
            # Start tor service as requested by user
            log_message "ACTION" "Starting Tor service"
            echo -e "${CYAN}Starting Tor service (sudo systemctl start tor@default)...${RESET}"
            local cmd_start="sudo systemctl start tor@default"
            output=$(eval "$cmd_start" 2>&1)
            exit_code=$?
            log_command "ACTION" "$cmd_start" "$output" "$exit_code"
            if [[ $exit_code -ne 0 ]]; then
                log_message "WARNING" "tor@default start failed, trying 'tor'"
                echo -e "${RED}Failed to start 'tor@default'. Trying 'tor' service name as fallback...${RESET}"
                cmd_start="sudo systemctl start tor"
                output=$(eval "$cmd_start" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd_start" "$output" "$exit_code"
                if [[ $exit_code -ne 0 ]]; then
                    log_message "ERROR" "Failed to start Tor service"
                    echo -e "${RED}Failed to start Tor service. Check your Tor installation.${RESET}"
                    return
                fi
                log_message "INFO" "Tor service started via fallback 'tor'"
            else
                log_message "INFO" "Tor service started via tor@default"
            fi
            echo -e "${GREEN}Tor service started (or already running).${RESET}"
            # Wait briefly for Tor to establish circuits
            log_message "ACTION" "Waiting 6 seconds for Tor bootstrap"
            echo -e "${CYAN}Waiting up to 8 seconds for Tor to accept connections on 127.0.0.1:9050...${RESET}"
            until journalctl -u tor@default | grep -q "Bootstrapped 100%"; do
    		sleep 2
	    done
            # Run torsocks curl to get exit node IP in the background (but capture its output)
            # Prefer torsocks if available; otherwise use curl --socks5-hostname 127.0.0.1:9050
            EXIT_NODE_IP=""
            local tor_resp
            if command -v torsocks >/dev/null 2>&1; then
                log_message "ACTION" "Fetching Tor exit IP via torsocks"
                cmd="torsocks curl -s --max-time 12 \"https://check.torproject.org/api/ip\""
                tor_resp=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$tor_resp" "$exit_code"
                if [[ -n "$tor_resp" ]]; then
                    EXIT_NODE_IP=$(echo "$tor_resp" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1 || true)
                fi
            else
                log_message "WARNING" "torsocks not available, using direct SOCKS curl"
                cmd="curl --socks5-hostname 127.0.0.1:9050 -s --max-time 12 \"https://check.torproject.org/api/ip\""
                tor_resp=$(eval "$cmd" 2>&1)
                exit_code=$?
                log_command "ACTION" "$cmd" "$tor_resp" "$exit_code"
                if [[ -n "$tor_resp" ]]; then
                    EXIT_NODE_IP=$(echo "$tor_resp" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1 || true)
                fi
            fi
            if [[ -n "$EXIT_NODE_IP" ]]; then
                log_message "INFO" "Tor exit node IP obtained: $EXIT_NODE_IP"
                echo -e "${GREEN}Exit node IP obtained: $EXIT_NODE_IP${RESET}"
            else
                log_message "WARNING" "Failed to obtain Tor exit node IP (bootstrap incomplete?)"
                echo -e "${RED}Could not obtain exit node IP via Tor. Tor might not have fully bootstrapped. Try again after a few seconds or check Tor logs.${RESET}"
            fi
            # Launch a new torsocks-enabled terminal window
            # -------------------------------------------------
		# Launch Tor-enabled terminal (Kali / XFCE)
		# -------------------------------------------------
		if ! command -v torsocks >/dev/null 2>&1; then
		    echo -e "${RED}torsocks is not installed.${RESET}"
		    log_message "ERROR" "torsocks not installed"
		    return
		fi

		if ! command -v exo-open >/dev/null 2>&1; then
		    echo -e "${RED}exo-open not found (XFCE required).${RESET}"
		    log_message "ERROR" "exo-open not found"
		    return
		fi

		REAL_USER="${SUDO_USER:-$USER}"
		USER_HOME=$(eval echo "~$REAL_USER")

		log_message "INFO" "Launching Tor-routed XFCE terminal as $REAL_USER"

		sudo -u "$REAL_USER" \
		    DISPLAY="$DISPLAY" \
		    XAUTHORITY="$USER_HOME/.Xauthority" \
		    exo-open --launch TerminalEmulator torsocks bash &
		    
		NETWORK_REPAIRED="Tor-routed terminal opened (torsocks)."

		echo -e "${GREEN}$NETWORK_REPAIRED${RESET}"
		log_message "INFO" "$NETWORK_REPAIRED"

            ;;
        3)
            log_message "INFO" "Tor option: Back to menu"
            echo -e "${CYAN}Returning to main menu...${RESET}"
            sleep 1
            return
            ;;
        *)
            log_message "WARNING" "Invalid Tor option: $tor_choice"
            echo -e "${RED}Invalid option. Returning to main menu.${RESET}"
            sleep 1
            return
            ;;
    esac
    # At the end, if we have both CURRENT_PUBLIC_IP and EXIT_NODE_IP set, show them quickly
    log_message "ACTION" "Tor setup summary"
    echo ""
    echo -e "${CYAN}Tor status summary:${RESET}"
    if [[ -n "$CURRENT_PUBLIC_IP" ]]; then
        echo -e "${GREEN}Your saved public IP:${RESET} $CURRENT_PUBLIC_IP"
    else
        echo -e "${RED}Your saved public IP: unknown${RESET}"
    fi
    if [[ -n "$EXIT_NODE_IP" ]]; then
        echo -e "${GREEN}Tor exit node IP:${RESET} $EXIT_NODE_IP"
    else
        echo -e "${RED}Tor exit node IP: unknown (Tor may not be ready)${RESET}"
    fi
    echo ""
    read -p "Press Enter to continue..." dummy
    log_message "INFO" "Tor enable completed"
}
# ---------------------------------------------------------
# Network Reset Function
# ---------------------------------------------------------
reset_network() {
    log_message "ACTION" "Option 99 selected: Full Network Reset (Kali Linux)"

    echo -e "${CYAN}=====================================${RESET}"
    echo -e "${GREEN}      NETWORK RESET / RECOVERY       ${RESET}"
    echo -e "${CYAN}=====================================${RESET}"
    echo ""
    echo -e "${RED}This will:${RESET}"
    echo " - Reset iptables & nftables firewall"
    echo " - Stop Tor routing"
    echo " - Restore original MAC address"
    echo " - Restart NetworkManager"
    echo " - Renew DHCP & reset DNS"
    echo ""

    read -p "Proceed with network reset? (y/N): " confirm
    [[ ! "$confirm" =~ ^[yY]$ ]] && {
        echo -e "${RED}Operation cancelled.${RESET}"
        log_message "INFO" "Network reset cancelled"
        sleep 1
        return
    }

    echo ""
    echo -e "${CYAN}[+] Starting network recovery...${RESET}"

    # --------------------------------------------------
    # 1) Stop Tor services
    # --------------------------------------------------
    echo -e "${CYAN}[1/9] Stopping Tor services...${RESET}"
    sudo systemctl stop tor tor@default 2>/dev/null || true
    log_message "ACTION" "Tor services stopped"

    # --------------------------------------------------
    # 2) RESET IPTABLES (FILTER + NAT)
    # --------------------------------------------------
    echo -e "${CYAN}[2/9] Resetting iptables firewall...${RESET}"
    sudo iptables -F 2>/dev/null || true
    sudo iptables -t nat -F 2>/dev/null || true
    sudo iptables -P INPUT ACCEPT 2>/dev/null || true
    sudo iptables -P OUTPUT ACCEPT 2>/dev/null || true
    sudo iptables -P FORWARD ACCEPT 2>/dev/null || true
    log_message "ACTION" "iptables reset (filter + nat)"

    # --------------------------------------------------
    # 3) RESET NFTABLES (Kali backend)
    # --------------------------------------------------
    echo -e "${CYAN}[3/9] Resetting nftables ruleset...${RESET}"
    if command -v nft >/dev/null 2>&1; then
        sudo nft flush ruleset 2>/dev/null || true
        log_message "ACTION" "nftables ruleset flushed"
    fi

    # --------------------------------------------------
    # 4) Restore original MAC address
    # --------------------------------------------------
    echo -e "${CYAN}[4/9] Restoring original MAC address...${RESET}"
    if [[ -n "$ORIGINAL_INTERFACE" && -n "$ORIGINAL_MAC" ]]; then
        sudo ip link set "$ORIGINAL_INTERFACE" down 2>/dev/null || true
        if command -v macchanger >/dev/null 2>&1; then
            sudo macchanger -m "$ORIGINAL_MAC" "$ORIGINAL_INTERFACE" >/dev/null 2>&1 || true
        fi
        sudo ip link set "$ORIGINAL_INTERFACE" up 2>/dev/null || true
        log_message "ACTION" "MAC restored on $ORIGINAL_INTERFACE"
    else
        log_message "INFO" "No original MAC stored, skipping"
    fi

    # --------------------------------------------------
    # 5) Restart NetworkManager
    # --------------------------------------------------
    echo -e "${CYAN}[5/9] Restarting NetworkManager...${RESET}"
    sudo systemctl restart NetworkManager 2>/dev/null || true
    log_message "ACTION" "NetworkManager restarted"

    # --------------------------------------------------
    # 6) Renew DHCP lease
    # --------------------------------------------------
    echo -e "${CYAN}[6/9] Renewing DHCP lease...${RESET}"
    if [[ -n "$ORIGINAL_INTERFACE" ]]; then
        sudo dhclient -r "$ORIGINAL_INTERFACE" 2>/dev/null || true
        sudo dhclient "$ORIGINAL_INTERFACE" 2>/dev/null || true
        log_message "ACTION" "DHCP renewed on $ORIGINAL_INTERFACE"
    fi

    # --------------------------------------------------
    # 7) Reset DNS
    # --------------------------------------------------
    echo -e "${CYAN}[7/9] Resetting DNS resolver...${RESET}"
    sudo resolvectl flush-caches 2>/dev/null || true
    sudo systemctl restart systemd-resolved 2>/dev/null || true
    log_message "ACTION" "DNS reset"

    # --------------------------------------------------
    # 8) Clear proxy environment variables
    # --------------------------------------------------
    echo -e "${CYAN}[8/9] Clearing proxy environment variables...${RESET}"
    unset http_proxy https_proxy ftp_proxy socks_proxy
    log_message "ACTION" "Proxy variables cleared"

    # --------------------------------------------------
    # 9) Connectivity test
    # --------------------------------------------------
    echo -e "${CYAN}[9/9] Testing internet connectivity...${RESET}"
    if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
        CONNECTIVITY_STATUS="${GREEN}✔ Internet reachable${RESET}"
    else
        CONNECTIVITY_STATUS="${RED}✘ Internet unreachable${RESET}"
    fi

    # --------------------------------------------------
    # FINAL STATUS SECTION (EXPLICIT)
    # --------------------------------------------------
    NETWORK_REPAIRED=$'Network recovery completed successfully:
✔ iptables firewall reset (FILTER + NAT)
✔ nftables rules cleared
✔ Tor routing disabled
✔ Original MAC restored
✔ NetworkManager restarted
✔ DHCP lease renewed
✔ DNS cache flushed'

    echo ""
    echo -e "${GREEN}Network reset completed.${RESET}"
    echo -e "$CONNECTIVITY_STATUS"

    log_message "INFO" "Network reset completed"
    sleep 2
}
# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
banner
start_animation
loading_bar
log_message "INFO" "Entering main loop"
while true; do
    banner2
    menu
    case $choice in
        1) change_mac ;;
        2) vpn_connect ;;
        3) proxychains_enable ;;
        4) tor_enable ;;
        5) i2p_connect ;;
        99) reset_network ;;
        9)
    	  echo -e "${CYAN}Restoring system configuration...${RESET}"
    	  restore_proxychains_config
    	  log_message "INFO" "User exited Feenix Anonimizer"
    	  exit 0
    	  ;;
        *)
            log_message "WARNING" "Invalid menu choice: $choice"
            echo -e "${RED}Invalid option!${RESET}"
            ;;
    esac
done

END_OF_FEENIX_SCRIPT

chmod +x "$SCRIPT_PATH"

echo
echo -e "${GREEN}[7/7] Setup completed successfully!${RESET}"
echo
echo -e "${CYAN}Results:${RESET}"
ls -ld "$TARGET_DIR"
ls -l "$SCRIPT_PATH"

echo
echo -e "${CYAN}Next steps:${RESET}"
echo -e "  ${GREEN}sudo $SCRIPT_PATH${RESET}"
echo
echo -e "${BOLD}Enjoy your anonymity toolkit 🚀${RESET}"

exit 0
