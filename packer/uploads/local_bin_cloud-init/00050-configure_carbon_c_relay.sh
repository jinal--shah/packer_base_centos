#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# configure_carbon_c_relay.sh
#
# Assumes the existence of certain env vars, and uses them
# to create the correct namespace for this instance's metrics.
#
#
CARBON_CONF=/etc/carbon-c-relay.conf
REQUIRED_VARS="
    AWS_INSTANCE_ID
    AWS_REGION
    EUROSTAR_ENV
    EUROSTAR_SERVICE_NAME
    EUROSTAR_SERVICE_ROLE
    EUROSTAR_RELEASE_VERSION
    METRICS_REMOTE_HOST
    METRICS_REMOTE_PORT
"

SUBSTITUTION_TOKENS="
    INSTANCE_ID
    AWS_REGION
    EUROSTAR_ENV
    EUROSTAR_SERVICE_NAME
    EUROSTAR_SERVICE_ROLE
    EUROSTAR_RELEASE_VERSION
    METRICS_REMOTE_HOST
    METRICS_REMOTE_PORT
"

INFO_FILES="
    /etc/eurostar/aws_instance_info
    /etc/eurostar/eurostar_service_info
    /etc/eurostar/remote_metrics_info
"
FAILED_VALIDATION=''

function check_var_defined() {
    var_name="$1"
    var_val="${!var_name}"
    if [[ -z $var_val ]]; then
        echo "$0 ERROR: You must pass \$$var_name to this script" >&2
        FAILED_VALIDATION="you bet'cha"
        return 1
    fi

}

for info_file in $INFO_FILES; do
    . $info_file
done

for this_var in $REQUIRED_VARS; do
    check_var_defined $this_var
done

if [[ ! -w $CARBON_CONF ]]; then
    echo "$0 ERROR: $CARBON_CONF does not exist or is not writable."
    echo "$0 ERROR: ... can't continue."
    FAILED_VALIDATION="you bet'cha"
fi

if [[ ! -z $FAILED_VALIDATION ]]; then
    echo "$0 EXIT: FAILURE. One of more required vars not passed to this script."
    exit 1
fi

INSTANCE_ID=$(echo $AWS_INSTANCE_ID | sed -e 's/^i-//')

echo "$0 INFO: replacing tokens in $CARBON_CONF"
for this_var in $SUBSTITUTION_TOKENS; do
    sed -i "s/__${this_var}__/${!this_var}/" $CARBON_CONF
done

echo "$0 INFO: metrics namespace transformed to: $(grep $INSTANCE_ID $CARBON_CONF)"

chkconfig carbon-c-relay on
chkconfig collectd on
chkconfig statsite on
echo "$0 INFO: starting up services"
# ... start up metrics-related services
#     ... always start carbon-c-relay before others.
service carbon-c-relay restart
service statsite restart
service collectd restart
exit 0

