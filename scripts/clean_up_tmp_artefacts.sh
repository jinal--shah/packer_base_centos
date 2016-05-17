#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# clean_up_tmp_artefacts.sh
#
TIMESTAMP="$(date +'%Y-%m-%d %H:%M:%S')"
PACKER_INFO="$PACKER_BUILD_NAME $PACKER_BUILD_TYPE"
rm -rf /etc/puppet 2>/dev/null
rm -rf /tmp/* 2>/dev/null
rm -rf /var/tmp/* 2>/dev/null
rm -rf /home/ec2-user/eif_puppet* /home/ec2-user/puppet-rsyslog-eif 2>/dev/null
echo -e "# $TIMESTAMP\n# $PACKER_INFO" >/.packer
