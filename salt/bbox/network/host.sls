
vlan:
  pkg.installed: []

{% for key, net in pillar.local.network.iteritems() %}
{% if net.get('configure', True) and net.link %}

{% set vnet = 'eth2' %}
{% if key == 'ostack' %}
{% set vnet = vnet + '.32' %}
{% elif key == 'storage' %}
{% set vnet = vnet + '.64' %}
{% elif key == 'nhb' %}
{% set vnet = vnet + '.80' %}
{% endif %}

{{ vnet }}_eth:
  network.managed:
    - name: {{ vnet }}
    - ipaddr: {{ net.ip4 }}/{{ net.cdir }}
    - enabled: True
    - type: eth
    - proto: static
{%- if net.gateway is defined %}
    - gateway: {{ net.gateway }}
{% endif %}

{% endif -%}

{% if net.routes is defined %}
{{ key }}_routes:
  network.routes:
    - name: {{ net.link }}
    - routes: {{ net.routes }}
{% endif -%}

{% endfor %}

