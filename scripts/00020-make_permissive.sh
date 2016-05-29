#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# make_permissive.sh
#
# ... turns off iptables and selinux policies
#
echo "$0 INFO: turning off iptables and selinux policies"

chkconfig iptables off \
&& setenforce 0

if ! getenforce 2>&1 | grep -i '^permissive\|disabled$' >/dev/null 2>&1
then
   echo "$0 ERROR: couldn't disable selinux ..."
   exit 1
fi

SELINUX_CFG=/etc/selinux/config
if [[ -f $SELINUX_CFG ]]; then
    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' $SELINUX_CFG
else
    echo "$0 ERROR: file does not exist: $SELINUX_CFG"
    exit 1
fi

