#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# get_eurostar_env_from_aws_tag.sh
#
# Gets env from aws tag and writes to /etc/eurostar/eurostar_service_info
#
# IMPORTANT *******************************************************
# SCRIPT MUST SEND NOTHING TO STDOUT EXCEPT THE DISCOVERED ENV NAME
# *****************************************************************
#
# At the moment, the tag key name can vary as can the value, so the logic is overly
# complicated.
#
# Once we retrofit the correct key name, 'env', across the AWS estate, this logic
# can be removed.
#
# *** Anything that is not mapped to one of list ***
# *** above is assumed to be an ephemeral env    ***
#
# ... REQUIRES
#     * awscli
#       * python,
#       * pip,
#     * IAM with ec2:DescribeTags Action in policy
#
AWS_INFO_FILE=/etc/eurostar/aws_instance_info
if [[ -f /etc/eurostar/aws_instance_info ]]; then
    . $AWS_INFO_FILE
fi


REQUIRED_VARS="
    AWS_INSTANCE_ID
    AWS_REGION
"
MAX_RETRIES=10   # ... no of times to try aws ec2 describe tags
POLL_INTERVAL=5 # ... seconds to wait between retries (for --dry-run only)

function check_var_defined() {
    var_name="$1"
    var_val="${!var_name}"
    if [[ -z $var_val ]]; then
        echo "$0 ERROR: You must pass \$$var_name to this script" >&2
        FAILED_VALIDATION="you bet'cha"
        return 1
    fi
}

for this_var in $REQUIRED_VARS; do
    check_var_defined $this_var
done

if [[ ! -z $FAILED_VALIDATION ]]; then
    echo "$0 EXIT: FAILURE. One of more required vars not passed to this script." >&2
    exit 1
fi

rc=0
for attempt in $(eval echo {1..$MAX_RETRIES}); do
    [[ $attempt -gt 1 ]] && echo "$0 INFO: ... retrying aws ec2 describe-tags dry-run"

    if ! aws ec2 describe-tags --region $AWS_REGION --dry-run 2>&1 \
        | grep 'would have succeeded' >/dev/null
        rc=0
        break
    then
        echo "$0 ERROR: can't run 'aws ec2 describe-tags'" >&2
        echo "$0 ERROR: ... check your IAM's role has the ec2:DescribeTags Action in its policy?" >&2
        rc=1
        sleep $POLL_INTERVAL
    fi

done

if [[ $rc -eq 1 ]]; then
    echo "$0 ERROR: failed too many times. Bailing"
    exit 1
fi

rc=0
for attempt in $(eval echo {1..$MAX_RETRIES}); do
    [[ $attempt -gt 1 ]] && echo "$0 INFO: ... retrying fetching env tag "

    aws_tags=$(
        aws ec2 describe-tags                                    \
            --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" \
            --region=$AWS_REGION                                 \
            --output=text \
        | awk {'print $2 " " $NF'} 2>/dev/null
    )

    if [[ -z $aws_tags ]]; then
        rc=1
        echo "$0 INFO: ... will retry in 1 second."
        sleep 1
    else
        rc=0
        break
    fi

done

if [[ $rc -eq 1 ]]; then
    echo "$0 ERROR: failed too many times. Bailing"
    exit 1
fi


# ... precedence of possible synonymous Keys env -> Environment -> Env
env_val=
env_val=$(echo "$aws_tags" | grep '^env ' 2>/dev/null | awk {'print $NF'})
if [[ -z $env_val ]]; then
    env_val=$(echo "$aws_tags" | grep '^Environment ' 2>/dev/null | awk {'print $NF'})
    echo "... matched 'Environment'" >&2
else
    echo "... matched 'env'" >&2
fi
if [[ -z $env_val ]]; then
    env_val=$(echo "$aws_tags" | grep '^Env ' 2>/dev/null | awk {'print $NF'})
    echo "... matched 'Env'" >&2
fi

# ... fail if still no value
if [[ -z $env_val ]]; then
    echo "$0 ERROR: couldn't find a suitable tag for 'env'." >&2
    echo "$0 ERROR: ... tried env, Environment and Env" >&2
    exit 1
fi

echo "$env_val"

exit 0

