#!/bin/bash

run_debug() {

  user="ubuntu"
  pass="ubuntu"

  echo "$user:$pass" | chpasswd
  touch /tmp/block-poweroff

}

#echo "make it debug"
#run_debug

echo "Environment ..."
env
echo

echo "more ..."
set
echo

echo "The filesystem ..."
df -a
echo

echo "List system drives ..."
lsblk -l -i -o name,maj:min,kname,type,model,size,state
echo

echo "Find funny maas commissioning files ..."
find /usr -type f | grep 'maas'
find /media -type f | grep 'maas'
