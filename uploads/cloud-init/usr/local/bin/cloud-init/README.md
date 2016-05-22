# cloud-init scripts

This cloud-init directory contains scripts that should be run in
sequence before your applications start.

The user-data script you apply to your instance-up configuration
should execute all of the scripts it finds in here in order.

Each should:

* be executable 
* named with a 5 digit prefix (zero-padded if needed) and hyphen
  to indicate when in the sequence it should run.
  e.g. 00005-\_runs\_after\_scripts\_00001-00004.sh
* begin with the appropriate #!
* not assume that previous cloud-init scripts have succeeded

# Cloud init only runs at launch-time

That's so important, I'll say it again.

_Cloud init only runs at launch-time_.

Don't expect a reboot to retrigger these babies.

## Immutable Infrastructure and Conscientious Cloud Init Usage

We aim to push the same AMI through each environment, so we can
be confident that if it works in dev, it will work in prod.

**Your scripts should not be installing packages, running puppet**
**or any other config-management tool - that should be done at**
**build time.**

Use cloud-init to gather data that can only be known at instance-up time.

e.g. the aws instance-id or an aws tag value.

## EXAMPLE: simple user-data script

        #!/bin/bash
        BIN_DIR=/usr/local/bin/cloud-init
        PATH=$PATH:$BIN_DIR
        SCRIPTS=$(ls -1 $BIN_DIR/[0-9][0-9][0-9][0-9][0-9]-*)
        for this_script in $SCRIPTS; do
            if [[ -x $this_script ]]; then
                echo "$0 INFO: .... executing $this_script"
                $this_script
            else
                echo "$0 WARN: ignoring $this_script (not executable)." >&2
            fi
        done

## Logging

STDOUT and STDERR from your scripts will end up in /var/log/cloud-init-output.log
