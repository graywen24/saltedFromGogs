{% set config = salt['alchemy.host'](grains.nodename) %}

{% for key, net in config.network.iteritems() %}
{% if net.link %}

{% if net.type == 'bond' %}
{% for iface in net['bond'] %}
{{ iface }}_bondslave:
  network.managed:
    - name: {{ iface }}
    - enabled: True
    - type: slave
    - master: {{ net.phys }}
{% endfor %}

{{ net.phys }}_bond:
  network.managed:
    - name: {{ net.phys }}
    - type: {{ net.type }}
    - mode: 802.3ad
    - miimon: 100
    - lacp_rate: fast
    - proto: manual
    - enabled: True
    - slaves: {{ net['bond']|join(' ') }}
    - miimon: 100
    - max_bonds: 1

{% else %}

{{ net.phys }}_bridgeport:
  network.managed:
    - name: {{ net.phys }}
    - enabled: True
    - type: eth
    - proto: manual

{% endif -%}

{{ net.link }}_bridge:
  network.managed:
    - name: {{ net.link }}
    - enabled: True
    - ipaddr: {{ net.ipv4 }}
    - type: bridge
    - proto: static
    - bridge: {{ net.link }}
    - delay: 0
    - ports: {{ net.phys }}
{%- if net.gateway is defined %}
    - gateway: {{ net.gateway }}
{% endif %}

{% endif -%}

{% endfor %}

