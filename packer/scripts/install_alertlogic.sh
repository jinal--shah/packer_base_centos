#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# install_alertlogic.sh

if [ -f /etc/eurostar/eurostar_service_info ]; then
  source /etc/eurostar/eurostar_service_info
fi

if [ ! -f "/etc/init.d/al-agent" ]; then
  echo "$0 INFO: install agent for alert logic" >&2
  yum install -y https://scc.alertlogic.net/software/al-agent-LATEST-1.x86_64.rpm
fi

# configure then provison the agent
/etc/init.d/al-agent configure --host ${ALERTLOGIC_HOST}
/etc/init.d/al-agent provision --key ${ALERTLOGIC_KEY} --inst-type role >/dev/null 2>&1
if [ -f /var/alertlogic/etc/host_crt.pem ] && [ -f /var/alertlogic/etc/host_key.pem ];
  then echo "$0 INFO: Alert Logic agent keys generated successfully" >&2
  else echo "$0 ERROR: Alert Logic agent keys failed to generate: /var/alertlogic/etc/host_*.pem" >&2
       exit 1
fi

# SELinux rules
semanage port --add --type syslogd_port_t --proto tcp 1514 && \
semanage port --add --type syslogd_port_t --proto tcp 2514

chkconfig al-agent off
