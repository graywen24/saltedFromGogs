
{% for key, net in pillar.local.network.iteritems() %}
{% if net.get('configure', True) and net.link %}

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
    - ipaddr: {{ net.ip4 }}/{{ net.cdir }}
    - type: bridge
    - proto: static
    - bridge: {{ net.link }}
    - delay: 0
    - ports: {{ net.phys }}
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

