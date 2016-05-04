#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# install_alertlogic.sh

REQUIRED_VARS="
    ALERTLOGIC_HOST
    ALERTLOGIC_KEY
"

function check_var_defined() {
    var_name="$1"
    var_val="${!var_name}"
    if [[ -z $var_val ]]; then
        echo "$0 ERROR: You must pass \$$var_name to this script" >&2
        FAILED_VALIDATION="you bet'cha"
        return 1
    fi
}

for this_var in $REQUIRED_VARS; do
    check_var_defined $this_var
done

if [[ ! -z $FAILED_VALIDATION ]]; then
    echo "$0 EXIT: FAILURE. One of more required vars not passed to this script."
    exit 1
fi

if [ ! -f "/etc/init.d/al-agent" ]; then
  echo "$0 INFO: install agent for alert logic" >&2
  yum install -y https://scc.alertlogic.net/software/al-agent-LATEST-1.x86_64.rpm
fi

# configure then provison the agent
/etc/init.d/al-agent provision --key ${ALERTLOGIC_KEY} --inst-type role
/etc/init.d/al-agent configure --host ${ALERTLOGIC_HOST}
if [ -f /var/alertlogic/etc/host_crt.pem ] && [ -f /var/alertlogic/etc/host_key.pem ];
  then echo "$0 INFO: Alert Logic agent keys generated successfully" >&2
  else echo "$0 ERROR: Alert Logic agent keys failed to generate: /var/alertlogic/etc/host_*.pem" >&2
       exit 1
fi

# SELinux rules
semanage port --add --type syslogd_port_t --proto tcp 1514    \
&& semanage port --add --type syslogd_port_t --proto tcp 2514

chkconfig al-agent off
