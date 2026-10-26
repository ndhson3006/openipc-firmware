#!/bin/sh
LOG_FILE="/tmp/api.log"
CONFIG_LOCK="/tmp/majestic_config.lock"

DAEMON="majestic"
DAEMON_PATH="/usr/bin/$DAEMON"
INIT_SCRIPT="/etc/init.d/S95majestic"

respond_json() {
    echo "Content-Type: application/json"
    echo ""
    echo "$1"
}

respond_error() {
    respond_json "{\"status\":\"error\",\"message\":\"$(json_escape "$1")\"}"
}

log_call() {
    script_name=$(basename "$0")
    echo "$(date '+%F %T') - ${script_name} called, QUERY_STRING=${QUERY_STRING}" >> "$LOG_FILE"
}

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

urldecode() {
    printf '%b' "$(printf '%s' "$1" | sed 's/+/ /g; s/%\([0-9A-Fa-f][0-9A-Fa-f]\)/\\x\1/g')"
}

qs_get() {
    raw=$(echo "$QUERY_STRING" | tr '&' '\n' | sed -n "s/^$1=\(.*\)\$/\1/p")
    urldecode "$raw"
}

is_valid_param() {
    case "$1" in
        .isp.exposure|\
        .video0.size|\
        .video0.fps|\
        .video0.bitrate|\
        .video0.codec|\
        .video0.rcMode|\
        .outgoing.enabled|\
        .outgoing.server|\
        .records.split|\
        .records.notime) return 0 ;;
        *) return 1 ;;
    esac
}

is_valid_value() {
    key="$1"; val="$2"
    case "$key" in
        .video0.codec)
            case "$val" in h264|h265) return 0 ;; *) return 1 ;; esac ;;
        .video0.rcMode)
            case "$val" in cbr|vbr|avbr) return 0 ;; *) return 1 ;; esac ;;
        .outgoing.enabled|.records.split|.records.notime)
            case "$val" in true|false) return 0 ;; *) return 1 ;; esac ;;
        .video0.fps|.video0.bitrate|.isp.exposure)
            case "$val" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac ;;
        .video0.size)
            case "$val" in [0-9]*x[0-9]*) return 0 ;; *) return 1 ;; esac ;;
        .outgoing.server)
            case "$val" in udp://*:*|rtp://*:*|rtsp://*) return 0 ;; *) return 1 ;; esac ;;
        *) return 1 ;;
    esac
}

set_and_reload() {
    key="$1"; val="$2"
    (
        flock -x 9
        cli -s "$key" "$val" >/dev/null 2>&1
        killall -HUP "$DAEMON" 2>/dev/null
    ) 9>"$CONFIG_LOCK"
}

daemon_running() {
    start-stop-daemon -t -K -q -x "$DAEMON_PATH"
}

daemon_start() {
    (
        flock -x 9
        "$INIT_SCRIPT" start >/dev/null 2>&1 9>&-
    ) 9>"$CONFIG_LOCK"
}

daemon_stop() {
    (
        flock -x 9
        "$INIT_SCRIPT" stop >/dev/null 2>&1 9>&-
    ) 9>"$CONFIG_LOCK"
}