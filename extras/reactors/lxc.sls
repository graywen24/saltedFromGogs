
{% if data['tag'] == 'lxc/container/enable_request' %}

enable_minion_for_container:
  runner.alchemy.container_enable:
  - target: {{ data['id'] }}
  - container: {{ data['data'].get('container') }}

{% endif %}

{% if data['tag'] == 'lxc/container/disable_request' %}

disable_minion_for_container:
  runner.alchemy.container_disable:
  - target: {{ data['id'] }}
  - container: {{ data['data'].get('container') }}

{% endif %}
