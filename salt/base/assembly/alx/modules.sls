# ensure all roles are set correctly
update_roles:
  salt.state:
  - sls: core.roles
  - tgt: '{{ pillar.target }}'

# install and activate ldap on all nodes - host or container
activate_ldap_auth:
  salt.state:
  - sls: ldap.client
  - tgt: '{{ pillar.target }}'
  - require:
    - salt: update_roles

# install and configure icinga satellites
install_icinga_satellites:
  salt.state:
  - sls: icinga.instance.installed
  - tgt: '{{ pillar.target }} and I@local:mole:satellites'
  - tgt_type: compound
  - require:
    - salt: activate_ldap_auth

configure_icinga_satellites:
  salt.state:
  - sls: icinga.instance.configured
  - tgt: '{{ pillar.target }} and I@local:mole:satellites'
  - tgt_type: compound
  - require:
    - salt: install_icinga_satellites

# install and configure icinga nodes
install_icinga_hosts:
  salt.state:
  - sls: icinga.instance.installed
  - tgt: '{{ pillar.target }} and I@local:mole:hosts'
  - tgt_type: compound
  - require:
    - salt: configure_icinga_satellites

configure_icinga_hosts:
  salt.state:
  - sls: icinga.instance.configured
  - tgt: '{{ pillar.target }} and I@local:mole:hosts'
  - tgt_type: compound
  - require:
    - salt: install_icinga_hosts

