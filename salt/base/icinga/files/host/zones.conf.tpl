/*
 * {{ pillar.defaults.hint }}
 */

{% set parent_zone = salt.icinga2.zone_parent() -%}
{% set parent_endpoints =  salt.icinga2.zone_parents() -%}

// endpoints we need to know about
object Endpoint NodeName {}
{% for node in parent_endpoints -%}
object Endpoint "{{ node }}" {}
{% endfor %}

object Zone "{{ parent_zone }}" {
  endpoints = [
{%- for node in parent_endpoints %}
     "{{ node }}",
{%- endfor %}
  ];
}

object Zone NodeName {
  endpoints = [ NodeName ];
  parent = "{{ parent_zone }}";
}

