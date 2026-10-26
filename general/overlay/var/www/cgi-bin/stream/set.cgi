#!/bin/sh
. "$(dirname "$0")/_common.sh"
log_call

param=$(qs_get param)
value=$(qs_get value)

[ -z "$param" ] || [ -z "$value" ] && { respond_error "missing param or value"; exit 0; }
is_valid_param "$param" || { respond_error "invalid param: $param"; exit 0; }
is_valid_value "$param" "$value" || { respond_error "invalid value for $param: $value"; exit 0; }
daemon_running || { respond_error "majestic is not running"; exit 0; }

set_and_reload "$param" "$value"
respond_json "{\"status\":\"ok\",\"action\":\"set\",\"param\":\"$(json_escape "$param")\",\"value\":\"$(json_escape "$value")\"}"