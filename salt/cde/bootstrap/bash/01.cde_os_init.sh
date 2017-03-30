#!/usr/bin/env bash

# set -x

SCRIPTDIR=$(dirname $0)
. $SCRIPTDIR/lib/webserver

# configure hosts
echo "Create a primitive hosts file ..."
cat <<EOF > /etc/hosts
127.0.0.1  localhost
127.0.0.1  ess-a1.cde.1nc ess-a1

127.0.0.1  repo.cde.1nc repo
127.0.0.1  salt.cde.1nc salt

EOF

# remove resolv.conf
echo "Disable and purge resolvconf ..."
apt-get -qq purge -y resolvconf
echo "" > /etc/resolv.conf

echo "Install temporary sources lists ..."
# configure apt
cat <<EOF > /etc/apt/sources.list
deb http://repo.cde.1nc/cde/ubuntu trusty main restricted universe multiverse
deb http://repo.cde.1nc/cde/ubuntu trusty-updates main restricted universe multiverse
deb http://repo.cde.1nc/cde/ubuntu trusty-security main restricted universe multiverse

EOF

rm  -f /etc/apt/sources.list.d/*
cat <<EOF > /etc/apt/sources.list.d/salt.list
deb http://repo.cde.1nc/cde/salt trusty main

EOF

echo "Ammend apt configuration - do not install recommends ..."
echo 'APT:Install-Recommends "false";' > /etc/apt/apt.conf.d/02recommends

echo "Make sure apt-key is available ..."
if ! apt-key list | grep -q "Cloud Services 1Net"; then
  apt-key add /srv/salt/base/repo/files/maas/alchemy.key
fi

# configure webserver
wsstart

echo "Cleaning apt cache ..."
apt-get -q clean

echo "Updating apt package database ..."
apt-get -qq update

echo "Running dist-upgrade ..."
apt-get -q dist-upgrade -y

echo "Install nfs-common ..."
apt-get -q -y install nfs-common

wsstop
