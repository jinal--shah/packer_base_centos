#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# use_eurostar_ssh_key_for_this_aws_account.sh
#
# In AWS dev, we have a registered 'eurostar' ssh key. 
# In AWS prod we have a different registered 'eurostar' ssh key
#
# To ssh in to an instance in prod we should require users to
# utilise the prod account's key to log in as our standard ec2-user. 
#
# On centos, the correct eurostar public key for this account is in
# the centos user's .ssh authorized_keys file, courtesy of aws
# standard launch process.
#
SRC_KEY_FILE=~centos/.ssh/authorized_keys
DEST_KEY_FILE=~ec2-user/.ssh/authorized_keys

echo "$0 INFO: overwriting ec2-user's key with the correct one for this account."

if [[ ! -r $SRC_KEY_FILE ]]; then
    echo "$0 ERROR: can't read centos user's authorized keys" >&2
    exit 1
fi

OFFICIAL_KEY=$(cat $SRC_KEY_FILE)
KEY_NAME=$(echo $OFFICIAL_KEY | awk {'print $NF'})

if [[ -f $DEST_KEY_FILE ]]; then
    if [[ -w $DEST_KEY_FILE ]]; then
        # ... delete any line for a key with this name
        sed -i "/.* $KEY_NAME$/d" $DEST_KEY_FILE
    else
        echo "$0 ERROR: can't open file $DEST_KEY_FILE for writing" >&2
        exit 1
    fi
fi

# ... append this account's key
echo "$OFFICIAL_KEY" >> $DEST_KEY_FILE
