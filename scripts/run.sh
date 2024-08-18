#!/system/bin/sh

WG_DATA_DIR="/data/adb/wireguard"
WG_CONFIG_FILE="$WG_DATA_DIR/wg0.conf"
WG_LOG_DIR="$WG_DATA_DIR/logs"
WG_LOG_FILE="$WG_LOG_DIR/wireguard.log"
SCRIPT_LOG_FILE="$WG_LOG_DIR/run.log"

BIN_PATH="$(dirname "$0")/../bin"
# add to path
export PATH="$BIN_PATH:$PATH"

DATE_FORMAT="+%m/%d %H:%M:%S"
export TZ=Asia/Shanghai

ERROR_SCRIPT_RUNNING=1
ERROR_WG_RUNNING=2
ERROR_BIN_MISSING=3
ERROR_CONFIG_MISSING=4
ERROR_START_FAILED=5
ERROR_STOP_FAILED=6

printLogInfo() {
    printf '[%s] INFO: %s\n' "$(date "$DATE_FORMAT")" "$*" | tee -a "$SCRIPT_LOG_FILE"
}

printLogError() {
    printf '[%s] ERROR: %s\n' "$(date "$DATE_FORMAT")" "$*" | tee -a "$SCRIPT_LOG_FILE" >&2
}

checkCommand() {
    command -v "$1" >/dev/null 2>&1
}

setupPermissions() {
    chown -R 0:0 "$WG_DATA_DIR"
    find "$WG_DATA_DIR" -type d -exec chmod 0700 {} +
    find "$WG_DATA_DIR" -type f -exec chmod 0600 {} +
}

envCheck() {
    for i in "wg" "wg-quick"; do
        if ! checkCommand "$i"; then
            printLogError "Missing executable file: $i"
            exit $ERROR_BIN_MISSING
        fi
    done
    if [ ! -f "$WG_CONFIG_FILE" ]; then
        printLogError "Missing configuration file: $WG_CONFIG_FILE"
        exit $ERROR_CONFIG_MISSING
    fi
    if [ ! -d "$WG_DATA_DIR" ]; then
        mkdir -p "$WG_DATA_DIR"
    fi
    if [ ! -d "$WG_LOG_DIR" ]; then
        mkdir -p "$WG_LOG_DIR"
    fi

    mv "$WG_LOG_FILE" "$WG_LOG_FILE.old" 2> /dev/null
    touch "$WG_LOG_FILE"

    setupPermissions
}

startWireguard() {
    envCheck
    if [ -n "$(wg show)" ] >/dev/null; then
        printLogInfo "Skip start, wireguard is already running"
        exit $ERROR_WG_RUNNING
    fi
    if ! wg-quick up "$WG_CONFIG_FILE" 2>&1 | tee "$WG_LOG_FILE"; then
        printLogError "Failed to start, Configuration error."
        exit $ERROR_START_FAILED
    fi
    printLogInfo "Wireguard started"
}

stopWireguard() {
    envCheck
    if [ -z "$(wg show)" ] >/dev/null; then
        printLogInfo "Skip stop, wireguard is not running"
        return
    fi
    if ! wg-quick down "$WG_CONFIG_FILE" 2>&1 | tee "$WG_LOG_FILE"; then
        printLogError "Failed to stop, Configuration error."
        exit $ERROR_STOP_FAILED
    fi
    printLogInfo "Stop wireguard"
}

mkdir -p "$WG_LOG_DIR"
LOCK_FILE="$WG_LOG_DIR/run.lock"
if [ -f "$LOCK_FILE" ]; then
    printLogError "Script already running."
    exit $ERROR_SCRIPT_RUNNING
else
    touch "$LOCK_FILE" && trap 'rm -f "$LOCK_FILE"' EXIT
fi

while getopts ":sk" signal; do
    case "$signal" in
    s)
        startWireguard
        ;;
    k)
        stopWireguard
        ;;
    ?)
        printLogError "Unknown options: $signal"
        ;;
    esac
done
