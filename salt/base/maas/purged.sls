
uninstall_pkgs:
  pkg.purged:
  - pkgs:
    - maas-cli
    - maas-cluster-controller
    - maas-region-controller
    - maas-common
    - maas
    - apache2
    - amtterm
    - ipmitool
    - libsoap-lite-perl
    - postgresql-client-common
    - postgresql-common
    - dbus

purge_pkgs:
  module.run:
  - name: pkg.autoremove
  - purge: True

maas:
  user.absent:
  - purge: True

postgres:
  user.absent:
  - purge: True

dhcpd:
  user.absent:
  - purge: True

messagebus:
  user.absent:
  - purge: True

etc_files:
  file.absent:
  - name: /etc/maas

loop_control:
  file.absent:
    - name: /dev/loop-control

loop_device:
  file.absent:
    - name: /dev/loop0

