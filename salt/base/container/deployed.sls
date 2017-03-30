# {# TODO: Refactor the container generation to a reactor/runner pair #}
{% set container = salt['pillar.get']('container', 'container_not_set') %}
{% set profile = salt['pillar.get']('profile', 'ubuntu') %}
{% set config = salt['alchemy.container'](container) %}
{% set optionals = {'network': False, 'append': False} %}
{% set fqdn = config.get('fqdn') %}

# check if the container is already available
container_available:
  alchemy.lxc_available:
    - name: {{ container }}

# create it if not
container_create:
  module.run:
    - name: lxc.create
    - m_name: {{ container }}
    - profile: {{ profile }}
    - onchanges:
      - alchemy: container_available

# set the minion id to prevent accidents
minon_id_set:
  file.managed:
  - name: /var/lib/lxc/{{ container }}/rootfs/etc/salt/minion_id
  - contents: {{ fqdn }}
  - makedirs: true
  - require:
    - module: container_create

# set the minion hints for further wam bam
{{ container }}_minon_hints_set:
  file.managed:
  - name: /var/lib/lxc/{{ container }}/rootfs/etc/salt/grains
  - source: salt://container/files/grains
  - template: jinja
  - require:
    - file: minon_id_set

# Delete a resolv.conf file if it exists - might be a link
resolv_conf_gone:
  file.absent:
  - name: /var/lib/lxc/{{ container }}/rootfs/etc/resolv.conf
  - onchanges:
    - module: container_create
  - require:
    - module: container_create

# now create the resolv.conf as a file - prevents the resolvconf package from touching it
resolv_conf:
  file.managed:
    - name: /var/lib/lxc/{{ container }}/rootfs/etc/resolv.conf
    - source: /etc/resolv.conf
    - require:
      - file: resolv_conf_gone

# create a initial hosts file for the container
hostsfile:
  file.managed:
  - name: /var/lib/lxc/{{ container }}/rootfs/etc/hosts
  - source: salt://core/files/hosts
  - template: jinja
  - context:
      config: {{ config }}
  - require:
    - module: container_create

# copy apt keys from host
apt_trusted_keys:
  file.copy:
  - name: /var/lib/lxc/{{ container }}/rootfs/etc/apt/trusted.gpg
  - source: /etc/apt/trusted.gpg
  - force: True
  - onchanges:
    - module: container_create
  - require:
    - module: container_create

# copy salt sources list from host
salt_sources_list:
  file.copy:
  - name: /var/lib/lxc/{{ container }}/rootfs/etc/apt/sources.list.d/salt.list
  - source: /etc/apt/sources.list.d/salt.list
  - require:
    - module: container_create

{% if config.network is defined %}
{% set optionals = {'network': True, 'append': optionals.append } %}
# if we have networks, create the included config file
container_network_conf:
  file.managed:
    - name: /var/lib/lxc/{{ container }}/network.conf
    - source: salt://container/files/network.conf
    - template: jinja
    - user: root
    - mode: 644
    - context:
        network_config: {{ config.network }}
    - onchanges:
      - module: container_create
    - require_in:
      - file: create_config

# and create the interfaces file inside the container
container_interfaces_conf:
  file.managed:
    - name: /var/lib/lxc/{{ container }}/rootfs/etc/network/interfaces
    - source: salt://container/files/interfaces
    - template: jinja
    - user: root
    - mode: 644
    - context:
        network_config: {{ config.network }}
    - onchanges:
      - module: container_create
{% endif %}

{% if config.lxcconf is defined %}
{% set optionals = {'network': optionals.network, 'append': True } %}
# if we have lxcconf entries create the config file from it
container_append_conf:
  file.managed:
    - name: /var/lib/lxc/{{ container }}/append.conf
    - source: salt://container/files/append.conf
    - template: jinja
    - user: root
    - mode: 644
    - context:
        append_config: {{ config.lxcconf }}
    - onchanges:
      - module: container_create
    - require_in:
      - file: create_config
{% endif %}

# create the container instance fstab file - not in etc
container_fstab:
  file.managed:
    - name: /var/lib/lxc/{{ container }}/fstab
    - source: salt://container/files/fstab
    - template: jinja
    - user: root
    - mode: 644
    - context:
        container: {{ container }}
        {% if config.mount is defined %}
        mount: {{ config.mount }}
        {% endif %}
    - onchanges:
      - module: container_create
    - require_in:
      - file: create_config

{% if config.mount is defined %}
{% for key, mount in config.mount.iteritems() %}
{% if mount.local is defined %}
# ensure the local part of the mount entry exists
local_dir_{{ key }}:
  file.directory:
    - name: {{ mount.local }}
    - makedirs: True
#    - user: root
#    - group: root
#    - dir_mode: 0775
    - require:
      - file: container_fstab
    - require_in:
      - file: create_config
{% endif %}

# create the remote part of the mount entry
remote_dir_{{ key }}:
  file.directory:
    - name: /var/lib/lxc/{{ container }}/rootfs/{{ mount.remote }}
    - makedirs: True
    - user: root
    - group: staff
    - dir_mode: 2775
    - require:
      - file: container_fstab
    - require_in:
      - file: create_config
{% endfor %}
{% endif %}

# now recreate the main configuration file
create_config:
  file.managed:
  - name: /var/lib/lxc/{{ container }}/config
  - source: salt://container/files/config
  - template: jinja
  - context:
      container: {{ container }}
      arch: {{ salt.pillar.get('lxc.container_profile:{}:options:arch'.format(profile), 'amd64') }}
      common: {{ config.get('common', 'ubuntu.common.conf') }}
      network: {{ optionals.network }}
      append: {{ optionals.append }}
  - require_in:
    - lxc: container_running

# start the container
container_running:
  lxc.running:
    - name: {{ container }}
    - onchanges:
      - module: container_create

# bootstrap the container, i.e. install the salt minion
{% if config.bootstrap == 1 %}
container_enable:
  event.send:
  - name: lxc/container/enable_request
  - container: {{ container }}
  - onchanges:
    - module: container_create
  - require:
    - lxc: container_running
{% endif %}
