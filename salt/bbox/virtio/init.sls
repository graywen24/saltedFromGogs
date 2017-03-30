

modules_in:
  file.blockreplace:
  - name: /etc/modules
  - content: |
      9pnet_virtio
      9p
      9pnet
  - append_if_not_found: True

modules_initramfs:
  file.blockreplace:
  - name: /etc/initramfs-tools/modules
  - content: |
      9pnet_virtio
      9p
      9pnet
  - append_if_not_found: True


ramfs_update:
  cmd.run:
  - name: update-initramfs -u
