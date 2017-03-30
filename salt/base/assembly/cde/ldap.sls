# Installs the ldap system with master, slave and management server
provide_ldap_master:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:ldapmaster'
  - tgt_type: compound
  - sls:
    - ldap.server

provide_ldap_slave:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:ldapslave'
  - tgt_type: compound
  - sls:
    - ldap.server
  - require:
    - salt: provide_ldap_master

provide_ldap_manager:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:ldapmgr'
  - tgt_type: compound
  - sls:
    - lam
