

has_sshd_base_config:
  file.managed:
  - name: /etc/ssh/sshd_config
  - source: salt://sshd/files/sshd_config.base

has_sshd_defaults:
  file.managed:
  - name: /etc/default/ssh
  - source: salt://sshd/files/ssh.defaults


sshd_service:
  service.running:
  - name: ssh
  - sig: sshd
  - watch:
    - file: has_sshd_base_config
    - file: has_sshd_defaults
