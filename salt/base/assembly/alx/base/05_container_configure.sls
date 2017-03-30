
infra_hosts_configure:
  salt.runner:
  - name: alchemy.hosts_configure
  - target: '{{ pillar.target }}'
