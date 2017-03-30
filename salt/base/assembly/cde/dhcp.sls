
{% if salt.pillar.get('bootstrap', False) %}
infra_dns:
  salt.runner:
  - name: nodes.gen_dhcp
  - environment: cde
  - require_in:
    - salt: provide_dhcp_server
{% endif %}

provide_dhcp_server:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:dhcp'
  - tgt_type: compound
  - sls:
    - dhcpd
