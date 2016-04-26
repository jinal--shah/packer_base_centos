#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# Will generate a file under /etc/eurostar/eurostar_service_info
# This file contains key=value pairs that can be sourced in to a 
# bash script etc ...
#
# It contains stuff that is useful to determine the name and type of this
# service amongst other things.
#
#
REQUIRED_VARS="
    METRICS_REMOTE_HOST
    METRICS_REMOTE_PORT
"

INFO_FILE="/etc/eurostar/remote_metrics_info"
FAILED_VALIDATION=''
OUTPUT_STR=""

function check_var_defined() {
    var_name="$1"
    var_val="${!var_name}"
    if [[ -z $var_val ]]; then
        echo "$0 ERROR: You must pass \$$var_name to this script" >&2
        FAILED_VALIDATION="you bet'cha"
    fi
}

function add_to_info_str() {
    var_name="$1"
    var_val="${!var_name}"
    key_val="$var_name=$var_val"
    if [[ -z $OUTPUT_STR ]]; then
        OUTPUT_STR="$key_val"
    else
        OUTPUT_STR="$OUTPUT_STR\n$key_val"
    fi
}

for this_var in $REQUIRED_VARS; do
    check_var_defined $this_var \
    && add_to_info_str $this_var
done

if [[ ! -z $FAILED_VALIDATION ]]; then
    echo "$0 EXIT: FAILURE. One of more required vars not passed to this script."
fi

mkdir -p $(dirname $INFO_FILE) 2>/dev/null
echo -e "$OUTPUT_STR\n" >$INFO_FILE

