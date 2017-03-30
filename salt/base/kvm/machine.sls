
{% set vhostname = salt['pillar.get']('vhostname', '') %}
{% set config = salt['pillar.get']('hosts:'+vhostname, '') %}
{% if grains.host == config.target %}

create_image_folder:
  file.directory:
  - name: /var/storage/local/images
  - makedirs: True

create_image:
  cmd.run:
  - name: qemu-img create -f {{ config.kvm.disk.format }} {{ config.kvm.disk.image }} {{ config.kvm.disk.size }}
  - unless:
    - test -f {{ config.kvm.disk.image }}
  - require:
    - file: create_image_folder

create_config:
  file.managed:
  - name: /tmp/{{ config.kvm.name }}.xml.import
  - source: salt://kvm/files/vm.xml.tpl
  - template: jinja
  - makedirs: True
  - mode: 0644
  - context:
      vhostname: {{ vhostname }}

define_domain:
  cmd.run:
  - name: virsh define /tmp/{{ config.kvm.name }}.xml.import
  - require:
    - file: create_config

autostart_domain:
  cmd.run:
  - name: virsh autostart {{ config.kvm.name }}
  - require:
    - cmd: define_domain

delete_config:
  file.absent:
  - name: /tmp/{{ config.kvm.name }}.xml.import
  - require:
    - cmd: define_domain


{% endif %}
