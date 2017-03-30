bridge-utils:
  pkg.installed: []

{% for key, net in pillar.local.network.iteritems() %} {# Loop over networks #}
{% if net.get('configure', True) and net.link %}       {# Handle if to be configured and link set #}

{% if net.type == 'phys' %}                            {# Physical network type #}
{{ key }}_phys:
  network.managed:
    - name: {{ net.phys }}
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ net.ip4 }}/{{ net.cdir }}

{% else %}                                             {# Bridge or bond #}

{{ net.phys }}_bridgeport:
  network.managed:
    - name: {{ net.phys }}
    - enabled: True
    - type: eth
    - proto: manual
    - require:
      - pkg: bridge-utils

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
    - require:
      - pkg: bridge-utils
{%- if net.gateway is defined %}  {# If there is a gateway ... #}
    - gateway: {{ net.gateway }}
{% endif %}          {# close gateway #}
{% endif -%}         {# close phys or virt #}

{% if net.routes is defined %}
{{ key }}_routes:
  network.routes:
    - name: {{ net.link }}
    - routes: {{ net.routes }}
{% endif -%}

{% endif -%}  {# close to be configured #}
{% endfor %}

