#!/bin/sh
. "$(dirname "$0")/_common.sh"
log_call
if daemon_running; then
    respond_json '{"status":"ok","message":"already running"}'
    exit 0
fi
daemon_start
if daemon_running; then
    respond_json '{"status":"ok","action":"daemon_start"}'
else
    respond_error "failed to start majestic"
fi