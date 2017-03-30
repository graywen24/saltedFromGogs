

ldap_sys_config:
  file.managed:
    - name: /etc/ldap/ldap.conf
    - source: salt://ldap/common/files/ldap.sys.conf.tpl
    - template: jinja
    - makedirs: true

