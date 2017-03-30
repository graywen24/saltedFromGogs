preseeds:
  file.recurse:
    - name: /etc/maas/preseeds
    - source: salt://maas/files/preseeds
    - user: root
    - group: root
    - dir_mode: 0775
    - file_mode: 0664
    - include_empty: True
#    - require:
#      - pkg: maas

templates:
  file.recurse:
    - name: /etc/maas/templates
    - source: salt://maas/files/templates
    - user: root
    - group: root
    - dir_mode: 0775
    - file_mode: 0664
    - include_empty: True
#    - require:
#      - pkg: maas
