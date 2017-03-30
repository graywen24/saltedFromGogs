
include:
  - icinga.instance.common.configured

# dont need zones dir
icinga_no_zonesdir:
  file.absent:
  - name: /etc/icinga2/zones.d
  - watch_in:
    - service: icinga_service

# dont need repo dir
icinga_no_repodir:
  file.absent:
  - name: /etc/icinga2/repository.d
  - watch_in:
    - service: icinga_service

host_zones_configured:
  file.managed:
  - name: /etc/icinga2/zones.conf
  - source: salt://icinga/files/host/zones.conf.tpl
  - template: jinja
  - makedirs: True
  - watch_in:
    - service: icinga_service

{{ grains.id }}_configured:
  file.managed:
  - name: /etc/icinga2/local.d/host.conf
  - source: salt://icinga/files/common/host.conf.tpl
  - template: jinja
  - makedirs: True
  - watch_in:
    - service: icinga_service
