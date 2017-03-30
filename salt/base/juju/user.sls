put_priv_key:
  file.managed:
  - name: /home/ubuntu/.ssh/id_rsa
  - source: salt://juju/files/ssh/juju_id_rsa
  - user: ubuntu
  - group: ubuntu
  - makedirs: true
  - mode: 0600

put_pub_key:
  file.managed:
  - name: /home/ubuntu/.ssh/id_rsa.pub
  - source: salt://juju/files/ssh/juju_id_rsa.pub
  - user: ubuntu
  - group: ubuntu
  - makedirs: true

ubuntu_ssh_config:
  file.managed:
  - name: /home/ubuntu/.ssh/config
  - source: salt://juju/files/ubuntu_ssh_config
  - user: ubuntu
  - group: ubuntu
  - mode: 0600
  - template: jinja
