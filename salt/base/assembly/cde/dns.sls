

{% if salt.pillar.get('bootstrap', False) %}
infra_dns:
  salt.runner:
  - name: nodes.gen_dns
  - environment: cde
  - require_in:
    - salt: provide_bind_server
{% endif %}

provide_bind_server:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:dns'
  - tgt_type: compound
  - sls:
    - bind
