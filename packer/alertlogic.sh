#!/usr/bin/env bash
set -ex
# check sanity 
if [ -f /etc/.alert-logic-provisioned ]; then
  exit 0;
fi
if [ ! ping -c1 alertlogic-tmc.aws.eurostar.com ]; then
  echo "INFO: failed to contact alert logic tmc - avoiding provisioning for the time being"
  exit 0;
fi
if [ ! -f "/etc/init.d/al-agent" ]; then
  echo "IFNO: install agent for alert logic"
  yum install -y https://scc.alertlogic.net/software/al-agent-LATEST-1.x86_64.rpm
fi
# configure then provison the agent
/etc/init.d/al-agent configure --host alertlogic-tmc.aws.eurostar.com
/etc/init.d/al-agent provision --key 1d38d8832e9d36240843db0f51b5326eba7233c1cc2f18c7f6 --inst-type role
# and again 
semanage port --add --type syslogd_port_t --proto tcp 1514 && \
semanage port --add --type syslogd_port_t --proto tcp 2514
#
# happy path for logic alerters
touch /etc/.alert-logic-provisioned;
exit 0;
