#!/system/bin/sh

WG_DATA_DIR="/data/adb/wireguard"
GENERAL_SERVICE_PATH="/data/adb/service.d/wireguard.service"

if [ ! -d "/sys/module/wireguard" ]; then
    abort "Error: wireguard kernel module not found!"
fi

# init data dir
if [ ! -d "$WG_DATA_DIR" ]; then
    mkdir -p "$WG_DATA_DIR/logs"
fi

# remove useless/old files
rm -f "$GENERAL_SERVICE_PATH"

# setup permissions
echo "- Setting up permissions"

set_perm_recursive "$MODPATH"     0 0 0700 0700
set_perm_recursive "$WG_DATA_DIR" 0 0 0700 0600
