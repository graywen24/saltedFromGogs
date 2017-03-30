
infra_dns:
  salt.runner:
  - name: nodes.gen_dns
  - environment: {{ pillar.target }}

infra_dhcp:
  salt.runner:
  - name: nodes.gen_dhcp
  - environment: {{ pillar.target }}

infra_enlist_commission:
  salt.runner:
  - name: maas.enlist
  - environment: {{ pillar.target }}
  - require:
    - salt: infra_dns
    - salt: infra_dhcp
