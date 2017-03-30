
{% if 'ldapmaster' in grains.roles -%}

ldap_ldif:
  file.managed:
  - name: /tmp/install.ldif
  - source: salt://ldap/server/files/install.ldif.tpl
  - template: jinja
  - user: openldap
  - group: openldap
  - require:
    - pkg: ldap_packages
    - service: slapd_up
  - onlyif:
    - /usr/sbin/slapcat | /usr/bin/awk 'END{ if (NR == 0) exit 0; exit 1}'

slapd_down:
  service.dead:
  - name: slapd
  - onchanges:
    - file: ldap_ldif

initial_data:
  cmd.run:
  - name: /usr/sbin/slapadd -l /tmp/install.ldif
  - user: openldap
  - group: openldap
  - require:
    - service: slapd_down
  - onchanges:
    - file: ldap_ldif

ldap_ldif_remove:
  file.absent:
  - name: /tmp/install.ldif
  - require:
    - cmd: initial_data
  - onchanges:
    - file: ldap_ldif

slapd_up_again:
  service.running:
  - name: slapd
  - require:
    - cmd: initial_data
  - onchanges:
    - file: ldap_ldif

{%- endif %}