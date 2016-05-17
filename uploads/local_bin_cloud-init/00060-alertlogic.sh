#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# alertlogic.sh
#
# Assumes the existence of certain env vars
# 

if [ -f /etc/eurostar/eurostar_service_info ]; then
  source /etc/eurostar/eurostar_service_info
fi

if [[ ${EUROSTAR_ENV} == "prod" ]]; then
  chkconfig al-agent on && service al-agent start
fi
