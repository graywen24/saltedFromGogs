#!/usr/bin/env bash

# set -x

SCRIPTDIR=$(dirname $0)
. $SCRIPTDIR/../lib/steps

description="Steps to reset the environment to before having a local minion"
steps[0]="reset:Remove minion an put minimal stage configuration before minion install"

minit $STEP

if action reset; then
  # configure salt
  echo "Running step $STEP ..."
  service salt-minion stop
  apt-get purge -y salt-minion
  rm -rf /etc/salt
  rm -rf /var/cache/salt
  echo "" > /etc/resolv.conf

# configure hosts
cat <<EOF > /etc/hosts
127.0.0.1       localhost
10.1.48.10      ess-a1 ess-a1.cde.1nc

10.1.48.10  repo repo.cde.1nc
10.1.48.102 salt salt.cde.1nc

EOF

  /srv/salt/cde/bootstrap/bash/10.cde_stageone.sh minion
  /srv/salt/cde/bootstrap/bash/10.cde_stageone.sh local
  salt-call container.destroyed test=false
fi

