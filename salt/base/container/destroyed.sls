{% set container = salt['pillar.get']('container', 'container_not_set') %}
{% set config = salt['alchemy.container'](container) %}

{{ container }}_absent:
  lxc.absent:
    - name: {{ container }}
    - stop: true

container_disable:
  event.send:
  - name: lxc/container/disable_request
  - container: {{ container }}
  - require:
    - lxc: {{ container }}_absent
