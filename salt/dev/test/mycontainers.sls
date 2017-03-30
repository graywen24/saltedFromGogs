{% set preselect = salt['pillar.get']('container', '') %}
{% set node = grains.nodename %}
{% set containers = salt['alchemy.node_container_list'](node) %}

{% for container in containers %}
{% set config = salt['alchemy.container'](container) %}

{{ container }}_config:
  test.configurable_test_state:
    - comment: {{ config }}

{% endfor %}
