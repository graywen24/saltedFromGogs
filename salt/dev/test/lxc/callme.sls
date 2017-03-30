{% set shortname = salt['pillar.get']('container', 'container_not_set') %}


{{ shortname }}_config:
  test.configurable_test_state

