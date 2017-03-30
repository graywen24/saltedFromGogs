
hostsfile:
  file.managed:
    - name: /etc/hosts
    - source: salt://core/files/hosts
    - context:
        config: {{ pillar.local }}
    - template: jinja

