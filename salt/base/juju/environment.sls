
get_env:
  file.managed:
  - name: /home/ubuntu/.juju/environments.yaml
  - source: salt://juju/files/environments.yaml
  - user: ubuntu
  - group: ubuntu
  - makedirs: true

get_ostack:
  file.managed:
  - name: /home/ubuntu/openstack.yaml
  - source: salt://juju/files/openstack.yaml
  - user: ubuntu
  - group: ubuntu
  - makedirs: true



