#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# install_cloud-init.sh
#
# Installs pythonic cloud-init, runs at S53, so before any
# services - read more here:
# https://cloudinit.readthedocs.io/en/latest/
#
# Assumes any default cloud-init files are under dir $UPLOADS
UPLOADS=/tmp/uploads/cloud-init
echo "$0 INFO: ... installing cloud-init"
echo "$0 INFO: ... checking required files uploaded"

if [[ ! -d $UPLOADS ]]; then
    echo "$0 ERROR: ... couldn't find uploads dir $UPLOADS" >&2
    exit 1
fi

# ... install
yum -y install cloud-init
cp -r $UPLOADS/* /

# ... verify
if ! yum info cloud-init | grep -i 'repo.*: installed' >/dev/null
then
    echo "$0 ERROR: ... can't find installed cloud-init in yum info" >&2
    exit 1
fi

# ... cleanup
rm -rf $UPLOADS

exit 0
