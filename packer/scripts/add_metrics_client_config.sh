#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# add_metrics_client_config.sh
#
# Installs:
#
# * cob (cob.py, yum plugin to treat S3 as a repo)
# * RPMs to provide:
#   * statsite (statsd replacement),
#   * collectd,
#   * carbon relay (which feeds to REMOTE_METRICS_HOST:REMOTE_METRICS_PORT)
#
METRICS_RPMS="
    collectd
    collectd-dns
    collectd-netlink
    collectd-disk
    collectd-utils
    carbon-c-relay
    statsite
    collectd-rrdtool
"
   tar -C /tmp -xzf /tmp/cob_bundle.tgz       \
&& tar -C /tmp -xzf /tmp/emon_bundle.tgz      \
&& cp -r /tmp/cob/* /                         \
&& yum -y install yum-utils cloud-init        \
&& yum-config-manager --enable eurostar_prod  \
&& yum -y install $METRICS_RPMS               \
&& mkdir -p /etc/collectd.d                   \
&& cp -r /tmp/emon/* /                        \
&& yum-config-manager --disable eurostar_prod \
&& rm -rf /tmp/{cob,emon}                     \
          /tmp/{cob,emon}_bundle.tgz

