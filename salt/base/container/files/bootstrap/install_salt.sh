#!/usr/bin/env bash

# set minimal hosts

repo="\n\n### ALCHEMY\n\
10.1.32.100 salt salt.cde.1nc\n\
10.1.32.101 repo.cde.1nc\n\
### ALCHEMY\n"
grep -q repo.cde.1nc /etc/hosts || echo -e $repo >> /etc/hosts

#cat <<EOF > /etc/network/interfaces
# The loopback network interface
#auto lo
#iface lo inet loopback

# all other interfaces are included from here
#source-directory interfaces.d

#EOF

cat <<EOF > /etc/apt/sources.list.d/saltstack.list
deb http://repo.cde.1nc/cde/salt trusty main
EOF

cat <<EOF > /etc/apt/sources.list
deb http://repo.cde.1nc/cde/ubuntu trusty main restricted universe multiverse
deb http://repo.cde.1nc/cde/ubuntu trusty-updates main restricted universe multiverse
deb http://repo.cde.1nc/cde/ubuntu trusty-security main restricted universe multiverse
EOF

wget -q -O - http://repo.cde.1nc/maas/alchemy.key | apt-key add -
apt-get -qq update
apt-get -q -y install salt-minion
