#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# create_ec2-user.sh
#
USER=ec2-user
ID=500
echo "$0 INFO: creating $USER with superuser abilities (part of wheel group)"
groupadd --gid $ID $USER

useradd --uuid $ID \
        --gid $ID  \
        -d /home/$USER -m \
        --shell /bin/bash \
        -G wheel,$USER    \
        $USER

if ! grep "^$USER:.*$ID:$ID:" /etc/passwd >/dev/null 2>&1
then
   echo "$0 ERROR: couldn't add user $USER correctly" >&2
   exit 1
fi

echo "$0 INFO:"
mkdir /home/$USER/.ssh \
&& cp /root/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys \
&& chown -R $USER:$USER /home/$USER \
&& chmod 0700 /home/$USER/.ssh \
&& chmod 0600 /home/$USER/.ssh/authorized_keys

if ! diff /root/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
then
    echo "$0 ERROR: failed to create ssh authorized keys for $USER" >&2
    exit 1
fi


echo "$0 INFO: ... enabling wheel group to use passwordless sudo ..."
sed -i 's/^\(# *\)\(%wheel.*NOPASSWD.*\)/\2/g' /etc/sudoers

echo "$0 INFO: ... removing root's authorized_keys file"
rm -rvf /root/.ssh/authorized_keys

