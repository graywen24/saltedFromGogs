
infra_hosts_deploy:
  salt.runner:
  - name: alchemy.hosts_deploy
  - environment: {{ pillar.target }}
{% if pillar.nodes is defined %}
  - nodes: {{ pillar.nodes }}
{% endif %}