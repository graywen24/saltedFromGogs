{% set envdomain = salt['pillar.get']('defaults:env', 'Bloody_hell!') %}

env_check:
  test.configurable_test_state:
    - comment: {{ envdomain }} and {{ pillar.cdos.mysql.hostip }}

file_check:
  file.managed:
  - name: /tmp/test.txt
  - source: salt://test/orch/template.txt
  - template: jinja

