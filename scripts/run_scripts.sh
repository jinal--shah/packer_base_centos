#!/bin/bash
# run_scripts.sh
#
# Boostrap script that runs all other scripts within the packer scripts dir
# that fit a pattern.
#
BIN_DIR=/tmp/scripts
PATH=$PATH:$BIN_DIR
SCRIPTS=$(ls -1 $BIN_DIR/[0-9][0-9][0-9][0-9][0-9]-*)
for this_script in $SCRIPTS; do
    if [[ ! -x $this_script ]]; then
        chmod a+x $this_script
    fi
    echo "$0 INFO: .... executing $this_script"
    env $this_script
done
