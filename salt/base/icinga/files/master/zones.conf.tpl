/*
 * {{ pillar.defaults.hint }}
 */

{% set endpoints = salt.icinga2.zone_endpoints() -%}

// endpoints we need to know about
{% for node in endpoints -%}
object Endpoint "{{ node }}" { host = "{{ salt.dnsutil.A(node)[0] }}" }
{% endfor %}

object Zone "{{ salt.icinga2.node_zone() }}" {
  endpoints = [
{%- for node in endpoints %}
     "{{ node }}",
{%- endfor %}
  ];
}

