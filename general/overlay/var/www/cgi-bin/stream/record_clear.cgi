#!/bin/sh
# record_clear.cgi — reset toggleCount va lastToggleAt ve 0.
# App goi khi bat dau session moi (vi du Start Session) de delta tinh lai tu 0.
. "$(dirname "$0")/_common.sh"
log_call

(
    flock -x 9
    printf '0\n' > /tmp/record_toggle_count 2>/dev/null
    printf '0\n' > /tmp/record_last_toggle_at 2>/dev/null
    respond_json '{"status":"ok","action":"record_clear","toggleCount":0,"lastToggleAt":0}'
) 9>"$CONFIG_LOCK"
