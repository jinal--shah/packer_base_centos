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
#
# needs to use epel repo

# Check for epel repo. Install if needed. Enable it.
# Remember original state to disable epel

echo "$0 INFO: ... installing aws cli"

echo "$0 INFO: ... checking for epel. Installing if needed."
EPEL_RPM_URI=https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
EPEL_REPO_FILE=/etc/yum.repos.d/epel.repo

if ! yum repolist all | awk {'print $1'} | grep '^epel$' 2>/dev/null
then
    echo "$0 ERROR: epel not installed. Can't continue." >&2
    exit 1
else
    echo "$0 INFO: ... Found epel. Will enable only for this installation."
fi

yum -y install python python-pip --enablerepo epel \
&& pip --no-cache-dir install --upgrade awscli

if ! aws --version >/dev/null 2>&1
then
    echo "$0 ERROR: aws client not installed in to path correctly." >&2
    echo "          ... See ERROR messages above." >&2
    exit 1
fi
exit 0
