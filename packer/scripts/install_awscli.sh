#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# install_awscli.sh
#
# Installs:
#
# * python
# * pip (yum package)
# * awscli

   yum -y install python python-pip \
&& pip install awscli

if ! aws --version >/dev/null 2>&1
then
    echo "$0 ERROR: aws client not installed in to path correctly." >&2
    echo "          ... See ERROR messages above." >&2
    exit 1
fi
exit 0
