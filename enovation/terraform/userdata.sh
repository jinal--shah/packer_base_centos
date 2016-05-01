#!/bin/bash
# user-data.sh - pass this to your cloud provider as user-data.
#
# Runs numbered scripts in sequence.
# Invoked by cloud-init during first launch.
#
# STDOUT and STDERR from your scripts will end up in /var/log/cloud-init-output.log
#
BIN_DIR=/usr/local/bin/cloud-init
PATH=$PATH:$BIN_DIR
SCRIPTS=$(ls -1 $BIN_DIR/[0-9][0-9][0-9][0-9][0-9]-*)
for this_script in $SCRIPTS; do
    if [[ -x $this_script ]]; then
        echo "$0 INFO: .... executing $this_script"
        $this_script
    else
        echo "$0 WARN: ignoring $this_script (not executable)." >&2
    fi
done

# TODO: move this to /usr/local/bin/cloud-init/99000-restart-service.sh
if [[ -f /etc/eurostar/eurostar_service_info ]]; then
    if [[ -z $EUROSTAR_SERVICE_NAME ]]; then
        echo "$0 ERROR: can't restart service as EUROSTAR_SERVICE_NAME not defined."
        exit 1
    fi
    service $EUROSTAR_SERVICE_NAME restart
fi

