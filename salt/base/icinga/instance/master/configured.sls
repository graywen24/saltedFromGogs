
include:
  - icinga.instance.common.configured
  - .database

{% if 'icinga_ca' in grains.roles %}

icinga_ca_exists:
  icinga2.ca_exists:
  - name: {{ grains.id }}
  - require:
    - file: icinga_pki_exists
    - sls: icinga.instance.common.configured
  - watch_in:
    - service: icinga_service

icinga_ca_crt_link:
  file.symlink:
  - name: /etc/icinga2/pki/ca.crt
  - target: /var/lib/icinga2/ca/ca.crt
  - require:
    - icinga2: icinga_ca_exists
  - require_in:
    - service: icinga_service

{% endif %}

icinga_ido_config:
  file.managed:
  - name: /etc/icinga2/features-available/ido-mysql.conf
  - source: salt://icinga/files/common/features/ido-mysql.conf.tpl
  - template: jinja
  - watch_in:
    - service: icinga_service

icinga_api_users:
  file.managed:
  - name: /etc/icinga2/local.d/api-users.conf
  - source: salt://icinga/files/master/api-users.conf.tpl
  - template: jinja
  - watch_in:
    - service: icinga_service

master_zones_configured:
  file.managed:
  - name: /etc/icinga2/zones.conf
  - source: salt://icinga/files/master/zones.conf.tpl
  - template: jinja
  - makedirs: True
  - watch_in:
    - service: icinga_service

# has repo dir
icinga_repodir:
  file.directory:
  - name: /etc/icinga2/repository.d
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
