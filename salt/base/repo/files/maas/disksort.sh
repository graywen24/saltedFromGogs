#!/bin/bash

# where to store the initramfs script
initram=/tmp/disksort

# handle command line args
search=$1
doinitram=$2

# directories
lookupdir=/sys/class/scsi_device
blockdir=/sys/block

# lines
removals=""
additions=""
cid=0

# Find the a controller id for a device model
gethostcontrollerid() {

  searchstring=$1
  if [ -d "$searchstring" ]; then
    searchstring=$( cat $searchstring/device/model)
  fi

  for d in $lookupdir/*
  do
    if grep -q "$searchstring" $d/device/model; then
      cid=$(basename "$d" | cut -d":" -f1)
      return $cid
    fi
  done
  return 0
}

handledevice() {

  gethostcontrollerid "$1"

  removals+="echo 1 > $1/device/delete;"
  additions="echo \"- - -\" > /sys/class/scsi_host/host${cid}/scan;$additions"

}

# Exit early if dunno what to do
if [ -z "$search" ]; then
  echo "Hmpf - disksort dunno what to do - bail out!"
  exit 0
fi

# Exit early if all good
if grep -q "$search" $blockdir/sda/device/model; then
  echo "All good - $search is primary device :)"
  exit 0
fi

# as sda is not what we've been looking for we can delete this already
handledevice "$blockdir/sda"
additions="sleep 1;$additions"

# remove the current occurance of our searched device
for sd in $blockdir/sd*
do
  if grep -q "$search" "$sd/device/model"; then
    handledevice "$sd"
  fi
done

echo "$removals"
echo "$additions"

lsblk -d -l -i -o name,maj:min,kname,type,model,size,state

if [ ! -z doinitram ]; then
cat << EOB > $initram
#!/bin/sh

PREREQS=""

prereqs() { echo "\$PREREQS"; }

case "\$1" in
    prereqs)
    prereqs
    exit 0
    ;;
esac

. /scripts/functions
_log_msg "rearrange disks ..."

$removals
$additions

EOB
fi
