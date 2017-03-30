
alchemy-defa:
  pkg.latest: []

defa-config:
  file.managed:
  - name: /etc/defa/defa.conf
  - source: salt://defa/files/defa.conf
  - template: jinja
  - makedirs: True

defa-service:
  service.running:
  - name: defa
  - watch:
    - file: defa-config

