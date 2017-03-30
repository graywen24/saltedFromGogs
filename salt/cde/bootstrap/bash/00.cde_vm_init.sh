#!/usr/bin/env bash

# set -x

logit() {
  logger -s -t cde_in_vm $1
}

if ! grep -q 9pnet /etc/modules; then
  logit "Adding 9p modules to modules file..."
  cat <<EOF >> /etc/modules

# added by cde configuration procedures
9pnet_virtio
9p
9pnet
EOF
fi

if ! grep -q 9pnet /etc/initramfs-tools/modules; then
  logit "Adding 9p modules to initramfs..."
  cat <<EOF >> /etc/initramfs-tools/modules

# added by cde configuration procedures
9pnet_virtio
9p
9pnet
EOF
  update-initramfs -u -k all

fi

if [ ! -d /var/storage/repo-a1.cde.1nc/repos ]; then
  logit "Creating repos mountpoint..."
  mkdir -p /var/storage/repo-a1.cde.1nc/repos
fi

if ! grep -q repos /etc/fstab; then
  logit "Adding repos to fstab ..."
  echo 'repos /var/storage/repo-a1.cde.1nc/repos 9p defaults,noatime 0 0' >> /etc/fstab
fi

if [ ! -d /var/storage/saltmaster-a1.cde.1nc/saltstack ]; then
  logit "Creating saltstack mountpoint..."
  mkdir -p /var/storage/saltmaster-a1.cde.1nc/saltstack
fi

if ! grep -q saltstack /etc/fstab; then
  logit "Adding saltstack to fstab ..."
  echo 'saltstack /var/storage/saltmaster-a1.cde.1nc/saltstack 9p defaults,noatime 0 0' >> /etc/fstab
fi

if [ $(df | grep -E 'repos|saltstack' -c) -lt 2 ]; then
  logit "Mounting missing mounts ..."
  mount -a
fi

if [ -d /var/storage/saltmaster-a1.cde.1nc/saltstack/debian ]; then
  if ! grep -q /srv /etc/fstab; then
    logit "On dev - bind mounting saltstack ..."
    echo '/var/storage/saltmaster-a1.cde.1nc/saltstack /srv none bind,defaults 0 0' >> /etc/fstab
    mount -a
  fi
fi
