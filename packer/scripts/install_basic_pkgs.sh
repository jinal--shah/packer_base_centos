#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# install_basic_pkgs.sh
#
# Installs:
#
# * packages we want on every node.
# * epel repo conf (installed but disabled)
#
# PKGS: ... list of pkgs which can come from epel
PKGS="
    curl
    wget
    vim-enhanced
"
echo    "$0 INFO: ... installing basic packages:"
echo -e "$0 INFO: ..." $PKGS

echo    "$0 INFO: ... checking for epel. Installing if needed."
EPEL_RPM_URI=https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
EPEL_REPO_FILE=/etc/yum.repos.d/epel.repo

if ! yum repolist all | awk {'print $1'} | grep '^epel$' 2>/dev/null
then
    yum clean headers dbcache
    echo "$0 INFO: ... installing epel repo for yum"
    wget -O /tmp/epel.rpm $EPEL_RPM_URI                 \
    && yum -y localinstall /tmp/epel.rpm                \
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

yum -y install $PKGS --enablerepo epel
