{% set preselect = salt['pillar.get']('container', 'cmd-a1') %}
{% set containers = salt['alchemy.container_list'](preselect) %}

{% for container in containers %}
{% set config = salt['alchemy.container'](container) %}

{{ container }}_config:
  test.configurable_test_state:
    - comment: {{ config }}

{% endfor %}
