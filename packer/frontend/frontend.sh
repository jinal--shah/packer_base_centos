#!/bin/bash
set -e
NODE_ENV=production

mkdir /etc/enovation-fe
cp /tmp/frontend/env_vars.* /etc/enovation-fe/

mv /tmp/frontend/frontend.init /etc/init.d/enovation_fe
chown root:root /etc/init.d/enovation_fe
chmod 755 /etc/init.d/enovation_fe
chkconfig enovation_fe on

# Install nodejs
curl -sL https://rpm.nodesource.com/setup_5.x | bash -
yum install -y epel-release
yum install -y nodejs-5.6.0 s3cmd 

mkdir /srv/enovation_fe
tar zxvf /tmp/frontend/enovation_fe_latest.tar.gz -C /srv/enovation_fe/

cd /srv/enovation_fe
npm config set progress=false
npm config set //registry.npmjs.org/:_authToken=f2a21df6-b37f-4589-b4a4-bf8b212683ab
npm install --ignore-scripts
npm install -g forever

#export NODE_ENV=production
#export EUROSTAR_ENV=perf
#sudo EUROSTAR_ENV=$EUROSTAR_ENV NODE_ENV=$NODE_ENV forever start  -l /var/log/enovation_fe/forever.log -o /var/log/enovation_fe/app.log -e /var/log/enovation_fe/app-err.log -a server/index.js
