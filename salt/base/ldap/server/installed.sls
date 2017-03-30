
include:
  - core.ca
  - ldap.common
  - ldap.server.initial

debconf:
  pkg.installed:
  - name: debconf-utils

touch_noslapd:
  file.touch:
  - name: /etc/ldap/noslapd

slapd_default:
  file.managed:
  - name: /etc/default/slapd
  - source: salt://ldap/server/files/slapd.default.tpl
  - template: jinja
  - makedirs: True
  - require:
    - file: touch_noslapd

slapd_config:
  file.managed:
  - name: /etc/ldap/slapd.conf
  - source: salt://ldap/server/files/slapd.conf.tpl
  - template: jinja
  - require:
    - file: touch_noslapd

ldap_preseed:
  debconf.set_file:
  - source: salt://ldap/server/files/debconf.tpl
  - template: jinja
  - require:
    - pkg: debconf
    - file: touch_noslapd

ldap_packages:
  pkg.installed:
  - pkgs:
    - slapd
    - ldap-utils
  - require:
    - debconf: ldap_preseed
    - file: slapd_default
    - file: slapd_config

install_ldap_ssl_certs:
  module.run:
  - name: state.sls
  - mods: core.certs
  - require:
    - pkg: ldap_packages

ldap_db_dir_set:
  file.directory:
  - name: {{ pillar.ldap.datadir }}
  - user: openldap
  - group: openldap
  - recurse:
    - user
    - group
  - require:
    - pkg: ldap_packages

ldap_dump_dir:
  file.directory:
  - name: {{ pillar.ldap.backupdir }}
  - user: openldap
  - group: openldap
  - mode: 775
  - require:
    - pkg: ldap_packages

kill_noslapd:
  file.absent:
  - name: /etc/ldap/noslapd
  - require:
    - file: ldap_db_dir_set
    - pkg: ldap_packages

slapd_up:
  service.running:
  - name: slapd
  - require:
    - file: kill_noslapd
    - sls: core.ca
    - module: install_ldap_ssl_certs
