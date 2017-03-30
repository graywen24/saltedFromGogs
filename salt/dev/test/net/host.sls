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
    - ipaddr: {{ net.ipv4 }}
    - mode: 802.3ad
    - miimon: 100
    - lacp_rate: fast
    - proto: static
    - enabled: True
    - slaves: {{ net['bond']|join(' ') }}
    - miimon: 100
    - max_bonds: 1
{%- if net.gateway is defined %}
    - gateway: {{ net.gateway }}
{% endif %}

{% else %}

{{ net.phys }}_eth:
  network.managed:
    - name: {{ net.phys }}
    - ipaddr: {{ net.ipv4 }}
    - enabled: True
    - type: eth
    - proto: static
{%- if net.gateway is defined %}
    - gateway: {{ net.gateway }}
{% endif %}

{% endif -%}

{% endif -%}

{% endfor %}

