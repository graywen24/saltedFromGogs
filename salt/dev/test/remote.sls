
{% set mytestval = salt['pillar.get']('testval', 'not_found') %}

{{ mytestval }}:
  test.succeed_without_changes:
    - name: {{ mytestval }}

