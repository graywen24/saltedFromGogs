{% set container = salt['pillar.get']('container', 'container_not_set') %}
{% set config = salt['alchemy.container'](container) %}

{{ container }}_absent:
  lxc.absent:
    - name: {{ container }}
    - stop: true

{{ container }}_data_absent:
  file.absent:
  - name: /var/storage/{{ container }}
  - require:
    - lxc: {{ container }}_absent
