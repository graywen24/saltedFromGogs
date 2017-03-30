
include:
  - maas.loopdevice
  - maas.postgres
  - maas.preseeds
  - maas.other

dbconfig.maas.region.controller:
  file.managed:
  - name: /etc/dbconfig-common/maas-region-controller.conf
  - source: salt://maas/files/db/dbconfig.maas
  - template: jinja
  - mode: 0600
  - user: root
  - makedirs: True
  - require:
    - sls: maas.loopdevice
    - sls: maas.postgres
    - sls: maas.preseeds
    - sls: maas.other

maas_user:
  user.present:
  - name: maas
  - home: /var/storage/maas
  - shell: /bin/false
  - gid_from_name: True
  - system: True
  - createhome: False
  - fullname: "MaaS systemuser"
  - require:
    - file: dbconfig.maas.region.controller

maas_storage_dir:
  file.directory:
  - name: /var/storage/maas
  - user: maas
  - group: maas
  - mode: 755
  - require:
    - user: maas_user

maas_data_mount:
  mount.mounted:
  - name: /var/lib/maas
  - device: /var/storage/maas
  - fstype: none
  - mkmnt: True
  - opts:
    - defaults
    - bind
    - noatime
    - nodiratime
  - require:
    - user: maas_user
    - file: maas_storage_dir

maas_package_install:
  pkg.latest:
  - name: maas
  - require:
    - mount: maas_data_mount

maas-admin:
  cmd.run:
  - name: maas-region-admin createadmin --username=$USER --password=$PASS --email=$MAIL
  - env:
    - USER: {{ pillar.maas.user }}
    - PASS: {{ pillar.maas.pass }}
    - MAIL: {{ pillar.maas.email }}
  - require:
    - pkg: maas
  - unless:
    - maas-region-admin apikey --username={{ pillar.maas.user }}
