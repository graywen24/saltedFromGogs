
infra_hosts_configure:
  salt.runner:
  - name: alchemy.hosts_configure
  - target: '{{ pillar.target }}'
{% if pillar.scope is defined %}
  - scope: {{ pillar.scope }}
{% endif%}
