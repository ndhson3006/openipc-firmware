#!/bin/sh
. "$(dirname "$0")/_common.sh"
log_call

if ! daemon_running; then
    respond_json '{"status":"ok","daemon":"stopped"}'
    exit 0
fi

exposure=$(cli -g .isp.exposure 2>/dev/null)
size=$(cli -g .video0.size 2>/dev/null)
fps=$(cli -g .video0.fps 2>/dev/null)
bitrate=$(cli -g .video0.bitrate 2>/dev/null)
codec=$(cli -g .video0.codec 2>/dev/null)
rcmode=$(cli -g .video0.rcMode 2>/dev/null)
enabled=$(cli -g .outgoing.enabled 2>/dev/null)
server=$(cli -g .outgoing.server 2>/dev/null)
split=$(cli -g .records.split 2>/dev/null)
notime=$(cli -g .records.notime 2>/dev/null)

respond_json "{\"status\":\"ok\",\"daemon\":\"running\",\"data\":{\"exposure\":\"$(json_escape "$exposure")\",\"size\":\"$(json_escape "$size")\",\"fps\":\"$(json_escape "$fps")\",\"bitrate\":\"$(json_escape "$bitrate")\",\"codec\":\"$(json_escape "$codec")\",\"rcMode\":\"$(json_escape "$rcmode")\",\"enabled\":\"$(json_escape "$enabled")\",\"server\":\"$(json_escape "$server")\",\"split\":\"$(json_escape "$split")\",\"notime\":\"$(json_escape "$notime")\"}}"