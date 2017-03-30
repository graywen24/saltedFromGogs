# Installs and updates the ldap authentication on all machines
install_icinga_instance:
  salt.state:
  - tgt: '{{ pillar.target }}'
  - sls:
    - icinga.instance.installed

configure_icinga_instance:
  salt.state:
  - tgt: '{{ pillar.target }}'
  - sls:
    - icinga.instance.configured
  - require:
    - salt: install_icinga_instance

