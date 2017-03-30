#!/usr/bin/env bash

SCRIPTDIR=$(dirname $0)
. $SCRIPTDIR/lib/steps

description="Steps to expand the salt dominion - get maas up and running, deploy"
steps[0]="maas:Setup maas service"

minit $STEP

if action maas; then

  salt-call container.destroyed maas-a1 test=false
  salt-key -y -d maas-a1.cde.1nc
  rm -rf /var/storage/maas-a1.cde.1nc
  salt-call container.deployed maas-a1 test=false

  echo -n "Waiting for minion key "
  while ! salt-key -l un | grep -q maas-a1.cde.1nc;
  do
    echo -n '.'
    sleep 1
  done
  echo

  salt-key -A -y

  echo -n "Waiting for minion to respond "
  while ! salt-run manage.up | grep -q maas-a1.cde.1nc;
  do
    echo -n '.'
  done
  echo

  salt maas-a1.cde.1nc state.sls core.roles
  salt maas-a1.cde.1nc state.sls core pillar='{"bootstrap": True}'
  salt maas-a1.cde.1nc state.sls system.upgrade
  salt maas-a1.cde.1nc state.sls debug.unlocked
  salt maas-a1.cde.1nc state.sls sshd
#  salt maas-a1.cde.1nc state.sls maas

fi


#if [ "HOSTNAME" != "saltmaster-a1" ]; then
#  echo "You need to run this on the saltmaster!"
#  exit 1
#fi


