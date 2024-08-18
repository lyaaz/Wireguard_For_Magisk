#!/system/bin/sh

MODPATH="/data/adb/modules/Wireguard_For_Magisk"
SCRIPTS_DIR="$MODPATH/scripts"
RUN_SCRIPT_PATH="$SCRIPTS_DIR/run.sh"

EVENTS="$1"
MONITOR_FILE="$3"

if [ "$MONITOR_FILE" = "disable" ]; then
    case "$EVENTS" in
        d)
            "$RUN_SCRIPT_PATH" -s
            ;;
        n)
            "$RUN_SCRIPT_PATH" -k
            ;;
        *)
            echo "Unknown event: $EVENTS" >&2
            ;;
    esac
fi
