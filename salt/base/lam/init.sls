
include:
  - ldap.common
  - lam.apache

alchemy-ldap-manager:
  pkg.installed: []

system_config:
  file.managed:
  - name: {{ pillar.lam.datadir }}/config/config.cfg
  - source: salt://lam/files/config.cfg
  - template: jinja
  - user: www-data
  - group: www-data

system_install_profiles:
  file.recurse:
  - name: {{ pillar.lam.datadir }}/config/templates/profiles
  - source: salt://lam/files/profiles
  - user: www-data
  - group: www-data
  - makedirs: True
  - clean: True

system_install_pdf:
  file.recurse:
  - name: {{ pillar.lam.datadir }}/config/templates/pdf
  - source: salt://lam/files/pdf
  - user: www-data
  - group: www-data
  - makedirs: True
  - clean: True


system_install_selfservice:
  file.managed:
  - name: {{ pillar.lam.datadir }}/config/selfService/Change.user
  - source: salt://lam/files/Change.user
#  - template: jinja
  - user: www-data
  - group: www-data
# TODO: handle binary format of the serialized php thing with jinja
#  - context:
#      ldap_server: {{ pillar.ldap.servers.split(' ')[0] }}
#      ldap_suffix: ou=people,{{ pillar.ldap.suffix }}
# {# s:9:"serverURL";s:{{ ldap_server|length }}:"{{ ldap_server }}";
# s:10:"LDAPSuffix";s:{{ ldap_suffix|length }}:"{{ ldap_suffix }}"; #}

{% for server in pillar.ldap.servers.split(' ') %}
{% set fqdn = server.replace('ldaps://', '').rstrip('/') %}
{% set id = fqdn.split('.')[0] %}
{{ fqdn }}_profile:
  file.managed:
  - name: {{ pillar.lam.datadir }}/config/{{ id }}.conf
  - source: salt://lam/files/profile.conf
  - template: jinja
  - user: www-data
  - group: www-data
  - context:
      server: {{ server.rstrip('/') }}
{% endfor %}

