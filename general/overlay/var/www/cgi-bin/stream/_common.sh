#!/bin/sh
# _common.sh — shared helpers for cgi-bin/stream/* scripts
# Sourced by each endpoint script, not executed directly by httpd.

LOG_FILE="/tmp/api.log"

# CONFIG_LOCK — shared lock file to serialize any cli -s / killall -HUP sequence.
# Concurrent CGI invocations (e.g. browser sending overlapping requests) each
# spawn their own process; without locking, two `cli -s` calls can race on
# reading/writing majestic.yaml at the same time, and one can read a
# partially-written (truncated) file mid-write from the other — silently
# dropping unrelated keys. Every write path MUST wrap its cli/killall calls
# in a flock block against this file. See apply_config() below.
CONFIG_LOCK="/tmp/majestic_config.lock"

# respond_json <json_string>
# Writes proper CGI header + JSON body. Always echo header first.
respond_json() {
    echo "Content-Type: application/json"
    echo ""
    echo "$1"
}

# respond_error <message>
# Consistent error shape across all endpoints.
respond_error() {
    respond_json "{\"status\":\"error\",\"message\":\"$1\"}"
}

# log_call
# Appends a line to LOG_FILE with timestamp, calling script name, and query string.
# Uses $0 (script path) trimmed to basename for readability.
log_call() {
    script_name=$(basename "$0")
    echo "$(date '+%F %T') - ${script_name} called, QUERY_STRING=${QUERY_STRING}" >> "$LOG_FILE"
}

# is_valid_param <full_key>
# Whitelist of tunable majestic.yaml keys accepted by stream/set.
# Client must pass the FULL key path (e.g. ".video0.bitrate"), not a short name —
# params live under different sections (isp, video0, outgoing, records), so no
# single prefix can be assumed. Extend this list as new tunables are supported.
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

# qs_get <key>
# Extracts a single value from $QUERY_STRING for key=value pairs joined by &.
# Safe (no eval) — plain sed extraction.
qs_get() {
    echo "$QUERY_STRING" | sed -n "s/.*\b$1=\([^&]*\).*/\1/p"
}

# set_and_reload <full_key> <value>
# Serializes a single `cli -s` + `killall -HUP majestic` under CONFIG_LOCK,
# so overlapping requests never read/write majestic.yaml at the same time.
# Requires busybox `flock` applet — verify with `which flock` on the camera.
set_and_reload() {
    key="$1"
    val="$2"
    (
        flock -x 9
        cli -s "$key" "$val" >/dev/null 2>&1
        killall -HUP majestic 2>/dev/null
    ) 9>"$CONFIG_LOCK"
}