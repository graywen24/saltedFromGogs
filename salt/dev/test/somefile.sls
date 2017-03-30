{% set bootstrap = True %}
{% set scope = none %}

test_minon_hints_set:
  file.managed:
  - name: /tmp/grains
    contents:
      - 'hints:'
{%- if bootstrap %}
      - '  bootstrap: True'
{%- endif %}
{%- if scope is not none %}
      - '  scope: {{ scope }}'
{%- endif %}
