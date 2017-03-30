
salt-minion-package:
  pkg.latest:
  - name: salt-minion
  - version: {{ pillar.defaults.salt.version }}
  - kwargs:
      dist_upgrade: True

salt-minion-config:
  file.recurse:
  - name: /etc/salt/minion.d
  - source: salt://salt/files/minion.d

salt-service:
  service.running:
  - name: salt-minion
  - watch:
    - file: salt-minion-config