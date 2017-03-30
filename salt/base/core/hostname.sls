
set_hostname:
  file.managed:
  - name: /etc/hostname
  - contents: {{ grains.host }}

set_minionid:
  file.managed:
  - name: /etc/minion_id
  - contents: {{ grains.host }}.{{ pillar.defaults.env }}
  - onlyif: stat /etc/salt
