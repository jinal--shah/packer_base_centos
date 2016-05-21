#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# os_upgrade.sh
#
# yum, yum, yum
#
yum clean all     \
&& yum upgrade -y \
&& yum clean all
