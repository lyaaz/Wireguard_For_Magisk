#!/system/bin/sh

WG_DATA_DIR="/data/adb/wireguard"
GENERAL_SERVICE_PATH="/data/adb/service.d/wireguard.service"

rm -r "$WG_DATA_DIR"
rm "$GENERAL_SERVICE_PATH"
