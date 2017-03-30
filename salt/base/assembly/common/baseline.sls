{% set target = pillar.get('target', none) %}
{% set hints_pillar = salt.pillar.get('hints:pillar') %}

baseline_prepare:
  salt.function:
  - name: saltutil.refresh_pillar
  - tgt: '{{ target }}'

baseline_set_roles:
  salt.state:
  - tgt: '{{ target }}'
  - sls:
    - core.roles
    - core.sync
  - require:
    - salt: baseline_prepare

baseline_apply_core_settings:
  salt.state:
  - tgt: '{{ target }}'
  - sls:
    - core
    - debug.unlocked
    - sshd
{%- if hints_pillar is not none %}
  - pillar: {{ hints_pillar }}
{%- endif %}
  - require:
    - salt: baseline_set_roles
