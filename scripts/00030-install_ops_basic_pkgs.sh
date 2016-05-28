#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# install_ops_basic_pkgs.sh
#
# Installs:
#
# * packages wanted on every node to help out ops work
# * epel repo conf (installed but disabled)
#
# PKGS: ... list of pkgs which can come from epel
PKGS="
    bind-utils
    curl
    lsof
    tcpdump
    telnet
    tree
    vim-enhanced
"

echo    "$0 INFO: ... installing basic packages:"
echo -e "$0 INFO: ..." $PKGS

yum clean headers dbcache
if ! yum repolist all | awk {'print $1'} | grep '^epel$' 2>/dev/null
then
    echo "$0 ERROR: epel not installed. Can't continue." >&2
    exit 1
else
    echo "$0 INFO: ... Found epel. Will enable only for this installation."
fi

yum -y install $PKGS --enablerepo epel

# ... make vim comments readable ...
echo "hi Comment ctermfg=6" >> /etc/vimrc

