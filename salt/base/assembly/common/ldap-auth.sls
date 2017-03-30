# Installs and updates the ldap authentication on all machines
configure_ldap_login:
  salt.state:
  - tgt: '{{ pillar.target }}'
  - sls:
    - ldap.client
