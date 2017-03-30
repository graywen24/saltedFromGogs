/*
 * {{ pillar.defaults.hint }}
 */

{% set parent_zone = salt.icinga2.zone_parent() -%}
{% set parent_endpoints = salt.icinga2.zone_parents() -%}
{% set node_zone = salt.icinga2.node_zone() -%}
{% set node_zone_endpoints = salt.icinga2.zone_endpoints() -%}


// endpoints we need to know about
{% for node in parent_endpoints -%}
object Endpoint "{{ node }}" {}
{% endfor -%}
{% for node in node_zone_endpoints -%}
object Endpoint "{{ node }}" { host = "{{ salt.dnsutil.A(node)[0] }}" }
{% endfor %}

object Zone "{{ parent_zone }}" {
  endpoints = [
{%- for node in parent_endpoints %}
     "{{ node }}",
{%- endfor %}
  ];
}

object Zone "{{ node_zone }}" {
  endpoints = [
{%- for node in node_zone_endpoints %}
     "{{ node }}",
{%- endfor %}
  ];
  parent = "{{ parent_zone }}";
}

