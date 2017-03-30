
{% if data['tag'] == 'icinga2/pki/gricket' %}

register_minion_for_cluster:
  runner.icinga2.pki_gricket:
  - target: {{ data['id'] }}

{% endif %}

{% if data['tag'] == 'icinga2/cluster/update_request' %}

update_minion_for_cluster:
  runner.icinga2.cluster_update_request_handler:
  - source: {{ data['id'] }}
  - data: {{ data['data'] }}

{% endif %}
