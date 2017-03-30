{% set workspace_result = salt['mine.get']('saltmaster-a1.cde.1nc', 'workspace') %}
{% set workspace = '' %}
{% if workspace_result['saltmaster-a1.cde.1nc'] is defined %}
{% set workspace = workspace_result['saltmaster-a1.cde.1nc'] %}
{% endif %}

workspace_config:
  test.configurable_test_state:
    - comment: {{ workspace }}

