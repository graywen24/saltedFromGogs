
ubuntu:
  user.present:
    - password: $6$qN4JQ.iF$FFE.Nm8dxrY82XuuNZ5CwxZNkphI5OF/p.jpmjLOXu.BVlC5vkONJBUiemhl/MBNCI/TcxCeB.FgodIUqLOrt1
    - gid_from_name: True
    - shell: /bin/bash
    - groups:
        - adm
        - sudo
        - cas

{% if 'ostack' in grains.roles %}
ubuntu-key:
  ssh_auth.present:
    - user: ubuntu
    - source: salt://juju/files/ssh/juju_id_rsa.pub

sudo_lah:
  file.managed:
  - name: /etc/sudoers.d/90-juju-ubuntu
  - contents: |
      ubuntu ALL=(ALL) NOPASSWD:ALL
      root ALL=(ALL) NOPASSWD:ALL
{%- if grains.nodename in ['keystone-a1', 'keystone-a2'] %}
      keystone ALL=(ALL) NOPASSWD:ALL
{%- endif %}
  - user: root
  - group: root
  - mode: 0440

{% endif %}



# meikang key
#AAAAB3NzaC1yc2EAAAADAQABAAAAgQCd1C4/uhWN06O7BZQg1kvA4v8F3tcbAwdM41eqnWVieyJA+2bV1Yp7+fsUg2FiAjcmi3iN/o4Czck02R/YV6Sq1PzxHhHAjEddEPjHbUFuV+BLkcYlqyhId4CBAAHH5FM9R2UDy3nlCwmKfHjYbsl8LdT2bw93W6RmF1aF3nRnIw==:
#  ssh_auth.present:
#    - user: ubuntu
#    - enc: ssh-rsa

