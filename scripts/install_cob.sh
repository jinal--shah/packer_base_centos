#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# install_cob.sh
#
# Installs cob (yum plugin that treats s3 as yum repo)
#
# Assumes needed cob files are under /tmp/uploads/cob
#
UPLOADS=/tmp/uploads/cob
echo "$0 INFO: ... installing cob (yum plugin for s3)"
echo "$0 INFO: ... checking required files uploaded"

if [[ ! -d $UPLOADS ]]; then
    echo "$0 ERROR: ... couldn't find uploads dir $UPLOADS" >&2
    exit 1
fi

# ... install
# ... make cob invokable - needs yum-config-manager (in yum-utils)
yum -y install yum-utils
cp -r $UPLOADS/* /

# ... verify
if ! sudo yum info yum | grep -i 'loaded plugins:.*\<cob\>' >/dev/null
then
    echo "$0 ERROR: ... yum can't find cob plugin after installation"
    exit 1
fi

# ... cleanup
rm -rf $UPLOADS

exit 0
