#!/usr/bin/env bash

# set -x

read -p "Do you really want to destroy this environment? yes/[no]: " -i "No" DO_DESTROY_ANSWER

DO_DESTROY=$(echo $DO_DESTROY_ANSWER | tr "[:upper:]" "[:lower:]")

outputter() {
  tput setaf 2
  sed 's/^/    /'
  tput setaf 9
}

if [ "$DO_DESTROY" = "yes" ]; then
  # configure salt

  echo "Destroying everything ..."

  echo "Killing all containers ..."
  salt-call container.destroyed test=false

  echo "Uninstall packages ..."
  apt-get -y purge salt-minion salt-master salt-common debootstrap lxc lxc-templates 2>&1 | outputter

  echo "Uninstall autoinstalled packages ..."
  apt-get -y autoremove --purge 2>&1 | outputter

  apt-get clean 2>&1 | outputter

  echo "Deleting leftover directories ..."
  rm -rf /etc/salt
  rm -rf /var/cache/salt
  rm -rf /var/log/salt
  rm -rf /var/cache/lxc
  rm -rf /usr/share/lxc
  rm -rf /etc/lxc

  echo "Killing all leftover processes ..."
  killall salt-master 2>&1 | outputter
  killall salt-minion 2>&1 | outputter

  read -p "Done - press Enter ..."

fi
