
{%- if 'ldapmaster' in grains.roles %}

ldap_ldif:
  file.managed:
  - name: /tmp/accounts.ldif
  - source: salt://ldap/files/accounts.ldif
  - user: openldap
  - group: openldap
  - template: jinja

slapd_down:
  service.dead:
  - name: slapd
  - require:
    - file: ldap_ldif

initial_data:
  cmd.run:
  - name: /usr/sbin/slapadd -l /tmp/accounts.ldif
  - user: openldap
  - group: openldap
  - require:
    - service: slapd_down
    - file: ldap_ldif

ldap_ldif_remove:
  file.absent:
  - name: /tmp/accounts.ldif
  - require:
    - cmd: initial_data

slapd_up:
  service.running:
  - name: slapd
  - require:
    - cmd: initial_data

{%- endif %}