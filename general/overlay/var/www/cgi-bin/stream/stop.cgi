#!/bin/sh
. "$(dirname "$0")/_common.sh"
log_call
if ! daemon_running; then
    respond_json '{"status":"ok","message":"already stopped"}'
    exit 0
fi
daemon_stop
if daemon_running; then
    respond_error "failed to stop majestic"
else
    respond_json '{"status":"ok","action":"daemon_stop"}'
fi