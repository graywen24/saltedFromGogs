include:
  - repo.gpgkey

apache2:
  pkg.installed: []

nodefault:
  file.absent:
    - name: /etc/apache2/sites-enabled/000-default.conf

repo_site_config:
  file.managed:
    - name: /etc/apache2/sites-available/alchemy.conf
    - source: salt://repo/files/site.default
    - template: jinja
    - watch_in:
      - service: apache2_refresh

repo_site_config_active:
  file.symlink:
    - name: /etc/apache2/sites-enabled/alchemy.conf
    - target: /etc/apache2/sites-available/alchemy.conf
    - watch_in:
      - service: apache2_refresh

cde_files:
  file.recurse:
    - name: /var/www/cde
    - source: salt://repo/files/cde
    - template: jinja
    - clean: True
    - user: www-data
    - group: www-data
    - dir_mode: 0775
    - file_mode: 0664
    - include_empty: True
    - makedirs: true
    - watch_in:
      - service: apache2_refresh

cde_site_config:
  file.managed:
    - name: /etc/apache2/sites-available/cde.conf
    - source: salt://repo/files/site.cde
    - template: jinja
    - watch_in:
      - service: apache2_refresh

cde_site_config_active:
  file.symlink:
    - name: /etc/apache2/sites-enabled/cde.conf
    - target: /etc/apache2/sites-available/cde.conf
    - watch_in:
      - service: apache2_refresh

apache2_refresh:
  service.running:
    - name: apache2
    - watch:
      - file: /etc/apache2/sites-available/alchemy.conf
      - file: /etc/apache2/sites-enabled/000-default.conf
    - require:
      - pkg: apache2

bootstrap:
  file.managed:
    - name: /var/www/salt/install_salt.sh
    - source: salt://container/files/bootstrap/install_salt.sh
    - makedirs: true

maasfiles:
  file.recurse:
    - name: /var/www/maas
    - source: salt://repo/files/maas
    - template: jinja
    - clean: True
    - user: root
    - group: root
    - dir_mode: 0775
    - file_mode: 0664
    - include_empty: True
    - makedirs: true

aptly_stable_repo:
  pkgrepo.managed:
    - humanname: AptlyStableRepo
    - name: deb http://repo.cde.1nc/cde/aptly trusty main
    - dist: trusty
    - file: /etc/apt/sources.list.d/aptly.list

aptly_config:
  file.managed:
    - name: /etc/aptly.conf
    - source: salt://repo/files/aptly.conf

apt-manage:
  file.managed:
    - name: /sbin/apt-manage
    - source: salt://repo/files/apt-manage
    - user: root
    - group: root
    - file_mode: 0755

aptly:
  pkg.installed: []

rsync:
  pkg.installed: []

uefi-trusty:
  file.symlink:
    - name: /var/www/repos/aptly/public/cde/ubuntu/dists/trusty/main/uefi
    - target: /var/www/repos/uefi/dists/trusty/main/uefi
    - makedirs: True

uefi-trusty-updates:
  file.symlink:
    - name: /var/www/repos/aptly/public/cde/ubuntu/dists/trusty-updates/main/uefi
    - target: /var/www/repos/uefi/dists/trusty-updates/main/uefi
    - makedirs: True

uefi-trusty-security:
  file.symlink:
    - name: /var/www/repos/aptly/public/cde/ubuntu/dists/trusty-security/main/uefi
    - target: /var/www/repos/uefi/dists/trusty-security/main/uefi
    - makedirs: True

