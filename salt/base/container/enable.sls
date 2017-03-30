
# make sure the container is started
container_running:
  lxc.running:
    - name: {{ pillar.enable.container }}

container_minion_pubkey:
  file.managed:
    - name: /var/lib/lxc/{{ pillar.enable.container }}/rootfs/etc/salt/pki/minion/minion.pub
    - contents: |
        {{ pillar.enable.pub | indent(8) }}
    - mode: 0644
    - makedirs: True

container_minion_privkey:
  file.managed:
    - name: /var/lib/lxc/{{ pillar.enable.container }}/rootfs/etc/salt/pki/minion/minion.pem
    - contents: |
        {{ pillar.enable.priv | indent(8) }}
    - mode: 0400
    - makedirs: True

# Enable the container by bootstrapping salt inside
container_apt_update:
  module.run:
    - name: lxc.run
    - m_name: {{ pillar.enable.container }}
    - cmd: apt-get -qq update
    - require:
      - lxc: container_running

# install and start the salt minion using the keys provided
container_salted:
  module.run:
    - name: lxc.run
    - m_name: {{ pillar.enable.container }}
    - cmd: apt-get -q -y install salt-minion
    - require:
      - module: container_apt_update
      - file: container_minion_pubkey
      - file: container_minion_privkey

