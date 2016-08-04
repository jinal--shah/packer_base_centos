#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# install_credstash.sh
#
# Installs:
#
# * python
# * pip (yum package)
# * credstash
#
# needs to use epel repo

# Check for epel repo. Install if needed. Enable it.
# Remember original state to disable epel

TMP_PKGS="
    autoconf
    automake
    bzip2-devel
    gcc
    git
    make
    pkgconfig
    zlib-devel
"

REQUIRED_PKGS="
    libffi-devel
    openssl-devel 
    python
    python-devel
    python-pip
"

TMP_PKGS_TO_ERASE=""

function is_installed {
    if yum list installed "$@" >/dev/null 2>&1; then
        true
    else
        false
    fi
}

echo "$0 INFO: ... installing credstash cli"

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

echo "$0 INFO: ... determining which tmp pkgs can be deleted after installing credstash"
for my_pkg in $TMP_PKGS; do
    if is_installed $my_pkg
    then
        echo "... won't remove pkg $my_pkg as installed prior to credstash."
    else
        echo "... will remove pkg $my_pkg after installing credstash."
        TMP_PKGS_TO_ERASE="$TMP_PKGS_TO_ERASE $my_pkg"
    fi
done

yum -y install $TMP_PKGS $REQUIRED_PKGS --enablerepo epel  \
&& pip --no-cache-dir install --upgrade requests[security] \
&& pip --no-cache-dir install --upgrade credstash

if ! credstash -h >/dev/null 2>&1
then
    echo "$0 ERROR: credstash client not installed in to path correctly." >&2
    echo "          ... See ERROR messages above." >&2
    exit 1
fi

[[ ! -z "$TMP_PKGS_TO_ERASE" ]] && yum remove -y $TMP_PKGS_TO_ERASE

exit 0
