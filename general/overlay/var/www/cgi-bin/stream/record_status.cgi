#!/bin/sh
. "$(dirname "$0")/_common.sh"
log_call

# Chi tra toggleCount + lastToggleAt (khong con recording).
# Doc duoi shared lock de nhat quan voi daemon (daemon ghi duoi LOCK_EX).
(
    flock -s 9

    count=$(cat /tmp/record_toggle_count 2>/dev/null)
    last_at=$(cat /tmp/record_last_toggle_at 2>/dev/null)

    case "$count"   in ''|*[!0-9]*) count=0 ;; esac
    case "$last_at" in ''|*[!0-9]*) last_at=0 ;; esac

    respond_json "{\"status\":\"ok\",\"toggleCount\":$count,\"lastToggleAt\":$last_at}"
) 9>"$CONFIG_LOCK"
