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
echo "$0 INFO: making sure ec2-user's key is the expected one for this instance"
DEST_KEY_FILE=~ec2-user/.ssh/authorized_keys
OFFICIAL_KEY=$(curl --retry 10 http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key)

echo "[$OFFICIAL_KEY]"
KEY_NAME=$(echo $OFFICIAL_KEY | awk {'print $NF'})

if [[ -f $DEST_KEY_FILE ]]; then
    if [[ -w $DEST_KEY_FILE ]]; then
        echo "$0 INFO: overwriting ec2-user's key with the correct one for this account."
        sed -i "/.* $KEY_NAME$/d" $DEST_KEY_FILE
        sed -i '/^\s*$/d' $DEST_KEY_FILE
    else
        echo "$0 ERROR: can't open file $DEST_KEY_FILE for writing" >&2
        exit 1
    fi
fi

# ... append this account's key
echo "$OFFICIAL_KEY" >> $DEST_KEY_FILE

