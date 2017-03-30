
include:
  - icinga.instance.common.running
  - icinga.instance.common.filesystem
  - icinga.instance.common.features

icinga2_master_host_dir:
  file.directory:
  - name: /etc/icinga2/hosts.d
  - watch_in:
    - service: icinga_service

# allow some special programs to the nagios user
icinga_sudoers_config:
  file.managed:
  - name: /etc/sudoers.d/20_nagios
  - source: salt://icinga/files/common/20_nagios.sudo.tpl
  - template: jinja
  - mode: 0440

# ensure icinga2 is configured for cluster features
icinga2_configured:
  file.managed:
  - name: /etc/icinga2/icinga2.conf
  - source: salt://icinga/files/common/icinga2.conf.tpl
  - template: jinja
  - watch_in:
    - service: icinga_service

templates_installed:
  file.recurse:
  - name: /etc/icinga2/global.d
  - source: salt://icinga/files/common/templates
  - clean: True
  - template: jinja
  - watch_in:
    - service: icinga_service

checks_installed:
  file.recurse:
  - name: /etc/icinga2/checks.d
  - source: salt://icinga/files/common/checks
  - makedirs: True
  - clean: True
  - template: jinja

plugins_installed:
  file.recurse:
  - name: {{ pillar.monitor.plugindir }}
  - source: salt://icinga/files/common/plugins
  - makedirs: True
  - clean: True
  - template: jinja
  - user: root
  - group: root
  - dir_mode: 0755
  - file_mode: 0755

constants_configured:
  file.managed:
  - name: /etc/icinga2/constants.conf
  - source: salt://icinga/files/common/constants.conf.tpl
  - template: jinja
  - makedirs: True
  - watch_in:
    - service: icinga_service

localconstants_configured:
  file.managed:
  - name: /etc/icinga2/local.d/constants.conf
  - source: salt://icinga/files/common/localconstants.conf.tpl
  - template: jinja
  - makedirs: True
  - watch_in:
    - service: icinga_service

checks_configured:
  file.managed:
  - name: /etc/icinga2/local.d/checks.conf
  - source: salt://icinga/files/common/checks.conf.tpl
  - template: jinja
  - makedirs: True
  - require:
    - file: checks_installed
    - file: constants_configured
    - file: localconstants_configured
  - watch_in:
    - service: icinga_service

{% if not 'icinga_ca' in grains.roles %}
icinga_ssl_cert:
  icinga2.cert_created:
  - name: {{ grains.id }}
  - watch_in:
    - service: icinga_service
  - require:
    - file: icinga_pki_exists

{% for node in salt.icinga2.zone_parents() %}

icinga_parent_cert_{{ node }}:
  icinga2.cert_installed:
  - name: {{ node }}
  - watch_in:
    - service: icinga_service
  - require:
    - file: icinga_pki_exists
{% endfor -%}
{% endif -%}

mole:
  grains.present:
    - order: 1
    - value: {{ salt.icinga2.node_mole() }}
