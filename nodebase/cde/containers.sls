containers:
  maas-a1:
    target: ess-a1
    ip4: 100
    network:
      manage:
        cnames:
          - maas
    roles:
      - maas
    lxcconf:
      lxc.cgroup.devices.allow:
        loopdevices: "b 7:* rwm" # Maas needs loop devices for image import
        loopcontrol: "c 10:237 rwm" # and access to the loop-control device
      lxc.aa_profile: "unconfined" # and actually allow mounting loops
  repo-a1:
    target: ess-a1
    ip4: 101
    network:
      manage:
        cnames:
          - repo
          - www
    mount:
      repo:
        local: /var/storage/{0}/repos
        remote: var/www/repos
    roles:
      - seed
      - repo
  saltmaster-a1:
    active: False
    packages:
      - python-ipaddr
    target: ess-a1
    ip4: 102
    network:
      manage:
        cnames:
          - salt
    roles:
      - seed
      - saltmaster
  micros-a1:
    target: ess-a1
    ip4: 103
    network:
      manage: {}
    roles:
      - seed
      - dns
      - dhcp
  micros-a2:
    target: ess-a2
    ip4: 104
    network:
      manage: {}
    roles:
      - dns
  lam-a1:
    target: ess-a1
    ip4: 105
    network:
      manage:
        cnames:
          - lam
    roles:
      - ldapsys
      - ldapmgr
  kibana-a1:
    target: ess-a1
    ip4: 106
    network:
      manage: {}
    roles:
      - kibana
  comm-a1:
    target: ess-a1
    ip4: 107
    network:
      manage:
        cnames:
          - smtp
          - sms
          - defa
    roles:
      - smarthost
      - smtprelay
      - smsgw
      - twofa
  ldap-a1:
    target: ess-a1
    ip4: 108
    network:
      manage: {}
    ssl:
      ldap:
        user: openldap
        group: openldap
        cert: ldap-a1.cde.1nc.crt
        key: ldap-a1.cde.1nc.key
    roles:
      - ldapsys
      - ldapmaster
  ldap-a2:
    target: ess-a2
    ip4: 111
    network:
      manage: {}
    ssl:
      ldap:
        user: openldap
        group: openldap
        cert: ldap-a2.cde.1nc.crt
        key: ldap-a2.cde.1nc.key
    roles:
      - ldapsys
      - ldapslave
  icinga-a1:
    target: ess-a1
    ip4: 113
    network:
      manage:
        cnames:
          - icinga
    roles:
      - icinga
      - icinga_web
      - icinga_ha_master
      - icinga_ca
      - icinga_db_master
    mole: masters
#  icinga-a2:
#    target: ess-a2
#    ip4: 114
#    network:
#      manage: {}
#    roles:
#      - icinga
#      - icinga_web
#      - icinga_ha_master
#    mole: masters
  icingadb-a1:
    target: ess-a2
    ip4: 115
    network:
      manage:
        cnames:
          - icingadb
    roles:
      - icinga
      - icinga_idodb
