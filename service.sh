#!/system/bin/sh

MODPATH="/data/adb/modules/Wireguard_For_Magisk"
SCRIPTS_DIR="$MODPATH/scripts"
WG_DATA_DIR="/data/adb/wireguard"
GENERAL_SERVICE_PATH="/data/adb/service.d/wireguard.service"

# wait boot completed
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 1
done

# wait network connected
until ping -w 1 -c 1 8.8.8.8; do
    sleep 1
done

rm -f "$WG_DATA_DIR/logs/"*

if [ ! -f "$MODPATH/disable" ]; then
    "$SCRIPTS_DIR/run.sh" -s > /dev/null 2>&1
fi

inotifyd "$SCRIPTS_DIR/inotify.sh" "$MODPATH:nd" > /dev/null 2>&1 &

if [ -f "$MODPATH/service.sh" ]; then
    mv -f "$MODPATH/service.sh" "$GENERAL_SERVICE_PATH"
fi
