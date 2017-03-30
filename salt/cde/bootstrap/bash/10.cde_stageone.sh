#!/usr/bin/env bash

# set -x

SCOPE_PARAM=''
if [ -f /etc/default/alchemy-scope ]; then
  . /etc/default/alchemy-scope
  SCOPE_PARAM="scope=$SCOPE"
fi

SCRIPTDIR=$(dirname $0)
. $SCRIPTDIR/lib/webserver
. $SCRIPTDIR/lib/steps

description="Steps to create a core salt system and deploy the containers for basic services"
steps[0]="scope:Tie a scope to the cde environment for testing and development"
steps[1]="salt:Setup the basic salt system on this machine"

minit $STEP

wsstart

if action scope; then
  read -p "Enter the name of the scope [dev, bbox]: " -i dev SCOPE_READ
  echo "SCOPE=$SCOPE_READ" > /etc/default/alchemy-scope
fi

if action salt; then
  # configure salt
  echo "Installing basic salt master ..."

  mkdir -p /etc/salt/master.d 2>&1 | outputter
  hostname -f > /etc/salt/minion_id 2>&1 | outputter

  cp /srv/salt/base/salt/files/master.d/* /etc/salt/master.d 2>&1 | outputter
  if [ ! -z $SCOPE ]; then
    echo "scope: $SCOPE" > /etc/salt/master.d/scope.conf
  fi

  echo "Using apt to install salt master ..."
  apt-get -qq update 2>&1 | outputter
  apt-get install -y salt-master # 2>$1 | outputter

  echo "Extending to basic salt system ..."
  salt-run -l info alchemy.bootstrap_gen_accept ess-a1.cde.1nc
  apt-get install -y salt-minion # 2>$1 | outputter

fi
