
{% set targetdomain = salt['pillar.get']('domain', 'domain_not_set') %}
{% if targetdomain == 'domain_not_set' %}

cdos_error:
  test.configurable_test_state:
  - changes: False
  - result: False
  - comment: |
      You need to give a domain in a custom pillar to make this run!
      Example: salt-run state.orchestrate orch.cdos pillar='{"domain": "nhb.1nc" }'

{% else %}

cdos_database:
  salt.state:
  - tgt: 'cdosdb-t1.{{ targetdomain }}'
  - sls:
    - cdosdb

cdos_data_init:
  salt.state:
  - tgt: 'cdosdb-t1.{{ targetdomain }}'
  - sls:
    - cdosdb.firsttime
  - require:
    - salt: cdos_database

cdos_applications:
  salt.state:
  - tgt: 'cdos-t1.{{ targetdomain }}'
  - sls:
    - cdos
  - require:
    - salt: cdos_database
    - salt: cdos_data_init

cdos_check_http:
  salt.function:
  - name: cmd.run
  - tgt: 'cdos-t1.{{ targetdomain }}'
  - arg:
    - wget -O /dev/null http://localhost
  - require:
    - salt: cdos_applications

cdos_add_2fa:
  salt.state:
  - tgt: 'cdosdb-t1.{{ targetdomain }}'
  - sls:
    - cdosdb.create2fa
  - require:
    - salt: cdos_check_http


{% endif %}