
roles:
  grains.present:
    - order: 1
    - value:
{%- for role in pillar.local.roles %}
      - {{ role }}
{%- endfor %}

