
infra_hosts_deploy:
  salt.runner:
  - name: alchemy.container_deploy
  - target: '{{ pillar.target }}'
