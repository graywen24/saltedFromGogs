
packages:
  pkg.purged:
  - pkgs:
    - bind9
    - libbind9-90

remove_configs:
  file.absent:
  - name: /etc/bind

remove_defaults:
  file.absent:
  - name: /etc/default/bind9.dpkg-dist

remove_lib:
  file.absent:
  - name: /var/lib/bind

remove_cache:
  file.absent:
  - name: /var/cache/bind



