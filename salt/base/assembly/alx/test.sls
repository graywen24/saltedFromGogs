infra_enlist_commission:
  salt.runner:
    - name: maas.testme
    - environment: {{ pillar.target }}
    - test: True

