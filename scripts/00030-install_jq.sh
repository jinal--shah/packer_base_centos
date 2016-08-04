#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# install_jq.sh
#
# Installs:
#
# * wget (to fetch jq)
# * jq
#

URL_JQ=https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
BIN_PATH=/usr/local/bin/jq 

yum -y install wget \
&& wget -O $BIN_PATH "$URL_JQ" \
&& chmod a+x $BIN_PATH

if ! jq --version >/dev/null 2>&1
then
    echo "$0 ERROR: jq not installed in to path correctly." >&2
    echo "          ... See ERROR messages above." >&2
    exit 1
fi
