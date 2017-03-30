#!/usr/bin/env bash

# Partitioning helper for maas curtin install
# two params will be passed:
# $1 - the type of partitioning wanted
# $2 - the path to the fstab file
# $3 - target mount point

# Retrieve the first disk device that is not in use by the installation process
getdevice() {

        disks=$(lsblk -rdn | awk 'BEGIN { ORS = " " } { if($6=="disk") print $1 }')
        for d in $disks
        do
                if ! grep -q "${d}" /etc/mtab; then
                        device=$d
                        return
                fi
        done
}

parttype=$1
fstabout=$2
target=$3
device="sda"

getdevice

echo "devices:"
lsblk -d

echo "Detected installation device as ${device}"

parttest() {

  # zapp the disk
  sgdisk -Z /dev/${device}

  # grub partition because of gpt table
  sgdisk -n 1:0:+1M -t 1:ef02 -c 1:bios_grub /dev/${device}

  # swap
  sgdisk -n 2:0:+64M -t 2:8200 -c 2:p_swap /dev/${device}
  mkswap /dev/${device}2
  echo "/dev/${device}2   swap    swap    defaults    0 0" > $fstabout

  # system
  sgdisk -n 3:0:+10G -t 3:8300 -c 3:p_system /dev/${device}
  mkfs.ext4 -q /dev/${device}3
  echo "/dev/${device}3   /       ext4    errors=remount-ro   0 1" >> $fstabout

  # var
  sgdisk -n 4:0:+10G -t 4:8300 -c 4:p_var /dev/${device}
  mkfs.ext4 -q /dev/${device}4
  echo "/dev/${device}4   /var    ext4    defaults,noatime   0 0" >> $fstabout

  # lxc container
  sgdisk -n 5:0:+20G -t 5:8300 -c 5:p_lxc /dev/${device}
  mkfs.ext4 -q /dev/${device}5
  echo "/dev/${device}5   /var/lib/lxc    ext4    defaults,noatime   0 0" >> $fstabout

  # storage
  sgdisk -n 6:0:0 -t 6:8300 -c 6:p_storage /dev/${device}
  mkfs.ext4 -q /dev/${device}6
  echo "/dev/${device}6   /var/storage    ext4    defaults,noatime   0 0" >> $fstabout

  mount /dev/${device}3 $target
  mkdir $target/var
  mount /dev/${device}4 $target/var

  mkdir -p $target/var/lib/lxc
  mkdir -p $target/var/storage
}


partbig() {

  # zapp the disk
  sgdisk -Z /dev/${device}

  # grub partition because of gpt table
  sgdisk -n 1:0:+1M -t 1:ef02 -c 1:bios_grub /dev/${device}

  # swap
  sgdisk -n 2:0:+512G -t 2:8200 -c 2:p_swap /dev/${device}
  mkswap /dev/${device}2
  echo "/dev/${device}2   swap    swap    defaults    0 0" > $fstabout

  # system
  sgdisk -n 3:0:+100G -t 3:8300 -c 3:p_system /dev/${device}
  mkfs.ext4 -q /dev/${device}3
  echo "/dev/${device}3   /       ext4    errors=remount-ro   0 1" >> $fstabout

  # var
  sgdisk -n 4:0:+100G -t 4:8300 -c 4:p_var /dev/${device}
  mkfs.ext4 -q /dev/${device}4
  echo "/dev/${device}4   /var    ext4    defaults,noatime   0 0" >> $fstabout

  # lxc container
  sgdisk -n 5:0:+500G -t 5:8300 -c 5:p_lxc /dev/${device}
  mkfs.ext4 -q /dev/${device}5
  echo "/dev/${device}5   /var/lib/lxc    ext4    defaults,noatime   0 0" >> $fstabout

  # storage
  sgdisk -n 6:0:0 -t 6:8300 -c 6:p_storage /dev/${device}
  mkfs.ext4 -q /dev/${device}6
  echo "/dev/${device}6   /var/storage    ext4    defaults,noatime   0 0" >> $fstabout

  mount /dev/${device}3 $target
  mkdir $target/var
  mount /dev/${device}4 $target/var

  mkdir -p $target/var/lib/lxc
  mkdir -p $target/var/storage
}


partsmall() {

  # zapp the disk
  sgdisk -Z /dev/${device}

  # grub partition because of gpt table
  sgdisk -n 1:0:+1M -t 1:ef02 -c 1:bios_grub /dev/${device}

  # swap
  sgdisk -n 2:0:+32G -t 2:8200 -c 2:p_swap /dev/${device}
  mkswap /dev/${device}2
  echo "/dev/${device}2   swap    swap    defaults    0 0" > $fstabout

  # system
  sgdisk -n 3:0:0 -t 3:8300 -c 3:p_system /dev/${device}
  mkfs.ext4 -q /dev/${device}3
  echo "/dev/${device}3   /       ext4    errors=remount-ro   0 1" >> $fstabout

  mount /dev/${device}3 $target

}

partbbox() {

  # zapp the disk
  sgdisk -Z /dev/${device}

  # grub partition because of gpt table
  sgdisk -n 1:0:+1M -t 1:ef02 -c 1:bios_grub /dev/${device}

  # swap
  sgdisk -n 2:0:+6G -t 2:8200 -c 2:p_swap /dev/${device}
  mkswap /dev/${device}2
  echo "/dev/${device}2   swap    swap    defaults    0 0" > $fstabout

  # system
  sgdisk -n 3:0:0 -t 3:8300 -c 3:p_system /dev/${device}
  mkfs.ext4 -q /dev/${device}3
  echo "/dev/${device}3   /       ext4    errors=remount-ro   0 1" >> $fstabout

  mount /dev/${device}3 $target

}

umountfs() {

  fs=/dev/${device}$1
  if grep -q "$fs" /etc/mtab; then
    umount $fs
  fi

}


case $1 in
 'partbig') partbig ;;
 'partsmall') partsmall ;;
 'parttest') parttest ;;
 'partbbox') partbbox ;;
 'umountfs') umountfs "$2" ;;
esac
