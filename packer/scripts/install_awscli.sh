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
    yum clean headers dbcache
    echo "$0 INFO: ... installing epel repo for yum"
    wget -O /tmp/epel.rpm $EPEL_RPM_URI                 \
    && yum -y localinstall /tmp/epel.rpm                   \
    && [[ -r $EPEL_REPO_FILE ]]                         \
    && sed -i 's/^enabled=1/enabled=0/' $EPEL_REPO_FILE \
    && rm -f /tmp/epel.rpm

    if ! yum repolist disabled | awk {'print $1'} | grep '^epel$' 2>/dev/null
    then
        echo "$0 ERROR: ... could not install epel."
        exit 1
    fi
else
    echo "$0: INFO: epel already installed."
fi

yum -y install python python-pip --enablerepo epel \
&& pip install awscli

if ! aws --version >/dev/null 2>&1
then
    echo "$0 ERROR: aws client not installed in to path correctly." >&2
    echo "          ... See ERROR messages above." >&2
    exit 1
fi
exit 0
