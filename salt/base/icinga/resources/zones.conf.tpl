/*
 * {{ pillar.defaults.hint }}
 */

{% set default_moles = salt.pillar.get('defaults:monitor:zones:default', {}) -%}
{% set moles = salt.pillar.get('defaults:monitor:zones:' + environment, default_moles) -%}
// endpoints we need to know about
{% for mole, parent in moles.iteritems() -%}
{% set nodes = salt.icinga2.molenodes(environment, mole, 'icinga-a1,kibana-a1,ess-a1,ess-a2') -%}
{% if nodes|length > 0 -%}
{% for nodename, node in nodes.iteritems() -%}
object Endpoint "{{ node.manage.host }}" { host = "{{ node.manage.ip4.split('/')[0] }}"; }
{% endfor -%}
{% endif -%}
{% endfor %}

{% for mole, parent in moles.iteritems() -%}
{% set nodes = salt.icinga2.molenodes(environment, mole, 'icinga-a1,kibana-a1,ess-a1,ess-a2') -%}

{% if nodes|length > 0 -%}
{% if not mole == 'hosts' -%}

object Zone "{{ environment }}-{{ mole }}" {
{% if parent != "None" -%}
  parent = "{{ parent|replace('ENV', environment) }}";
{% endif -%}
  endpoints = [
{%- for nodename, node in nodes.iteritems() %}
     "{{ node.manage.host }}",
{%- endfor %}
  ];
}

{%- else %}
{%- for nodename, node in nodes.iteritems() %}
object Zone "{{ node.manage.host }}" {
{%- if parent != "None" %} parent = "{{ parent|replace('ENV', environment) }}"; {% endif -%}
endpoints = [ "{{ node.manage.host }}" ]; }
{%- endfor -%}

{% endif -%}
{% endif %}
{% endfor %}
