bridge-utils:
  pkg.installed: []

vlan:
  pkg.installed: []


{% for key, net in pillar.local.network.iteritems() %}
{% if net.get('configure', True) and net.link %}

{% set vnet = 'eth2' %}
{% if key == 'ostack' %}
{% set vnet = vnet + '.32' %}
{% elif key == 'storage' %}
{% set vnet = vnet + '.64' %}
{% elif key == 'ha' %}
{% set vnet = vnet + '.80' %}
{% endif %}

{{ vnet }}_bridgeport:
  network.managed:
    - name: {{ vnet }}
    - enabled: True
    - type: eth
    - proto: manual

{{ net.link }}_bridge:
  network.managed:
    - name: {{ net.link }}
    - enabled: True
    - ipaddr: {{ net.ip4 }}/{{ net.cdir }}
    - type: bridge
    - proto: static
    - bridge: {{ net.link }}
    - delay: 0
    - ports: {{ vnet }}
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

