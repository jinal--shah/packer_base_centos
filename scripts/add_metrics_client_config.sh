#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# add_metrics_client_config.sh
#
# Installs:
#
# * cob (cob.py, yum plugin to treat S3 as a repo)
# * RPMs to provide these services:
#   * statsite (statsd replacement),
#   * collectd,
#   * carbon relay (which feeds to REMOTE_METRICS_HOST:REMOTE_METRICS_PORT)
#
# The services will be turned off by default.
# On instance-up we expect the carbon-c-relay to be configured correctly
# with runtime vars e.g. aws instance-id
# The services should be started after this happens
# (and then set to start on boot)
#
METRICS_RPMS="
    carbon-c-relay
    collectd
    collectd-disk
    collectd-dns
    collectd-netlink
    collectd-rrdtool
    collectd-utils
    statsite
"
YUM_EMON_CONF=etc/yum.repos.d/emon.repo

   tar -C /tmp -xzf /tmp/cob_bundle.tgz        \
&& tar -C /tmp -xzf /tmp/emon_bundle.tgz       \
&& cp -r /tmp/cob/* /                          \
&& cp /tmp/emon/$YUM_EMON_CONF /$YUM_EMON_CONF \
&& yum -y install yum-utils cloud-init         \
&& yum-config-manager --enable eurostar_prod   \
&& yum -y install $METRICS_RPMS                \
&& mkdir -p /etc/collectd.d                    \
&& cp -r /tmp/emon/* /                         \
&& yum-config-manager --disable eurostar_prod  \
&& rm -rf /tmp/{cob,emon}                      \
          /tmp/{cob,emon}_bundle.tgz

for service in carbon-c-relay collectd statsite; do
    service $service stop >/dev/null 2>&1
    chkconfig $service off
done

exit 0
