{% set hostname = salt['pillar.get']('host', 'ess-a1') %}
{% set config = salt['alchemy.host'](hostname) %}

{{ hostname }}_config:
  test.configurable_test_state:
    - comment: {{ config }}

