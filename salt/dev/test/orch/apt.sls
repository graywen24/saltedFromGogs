
{% set workspace_result = salt['mine.get']('saltmaster-a1.cde.1nc', 'workspace') %}
{% set workspace = '' %}
{% if workspace_result['saltmaster-a1.cde.1nc'] is defined %}
{% set workspace = workspace_result['saltmaster-a1.cde.1nc'] %}
{% endif %}


{% if workspace != '' %}
set_dev_repos:
  salt.state:
  - tgt: 'cdos-t1*'
  - saltenv: {{ workspace }}
  - sls:
    - core.apt
{% endif %}

