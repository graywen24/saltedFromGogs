/*
* {{ pillar.defaults.hint }}
*/

{% for endpoint in pillar.zone_endpoints -%}
object Endpoint "{{ endpoint }}" {
  host = "{{ salt.dnsutil.A(endpoint)[0] }}"
}

{% endfor -%}

object Zone "{{ pillar.zone }}" {
  endpoints = {{ salt.icinga2.pytoicingalist(pillar.zone_endpoints) }}
  parent = "{{ pillar.parent_zone }}"
}

{% if pillar.mole != 'hosts' %}
object Service "cluster_{{ pillar.zone }}" {
  import "generic-service"
  display_name = "cluster.zones.{{ pillar.zone }}"
  check_command = "cluster-zone"
  host_name = "{{ grains.id }}"
  vars.cluster_zone = "{{ pillar.zone }}"
}
{% endif %}