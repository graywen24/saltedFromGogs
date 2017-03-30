monitor:
  ca_master: icinga-a1.cde.1nc
  plugindir: /usr/lib/nagios/alchemy
  features:
    common:
      - api
      - checker
      - command
      - mainlog
    masters:
      - ido-mysql
      - livestatus
      - notification
      - graphite
    satellites:
      - notification
  oslist:
    linux:
      - Ubuntu
      - RedHat
    windows:
      - Windows
  basemole: hosts
  moles:
    masters:
      parent: None
      zone: cde-masters
      endpoints:
        - icinga-a1.cde.1nc
  checks:
    linux:
      - ssh
      - icinga
      - users
      - procs
      - process.salt-minion:
          cpu_warn: 10
          cpu_crit: 20
      - apt
      - cluster
    host:
      - cpu
      - mem
      - disk
      - load
    saltmaster:
      - process.salt-master: { "cpu_warn": 10, "cpu_crit": 20 }
    icinga_idodb:
      - mysql
    icinga_web:
      - http
    icinga_ha_master:
      - outdated
      - ido
    ldapmaster:
      - ldap
    ldapslave:
      - ldap
    ldapmgr:
      - http
    maas:
      - http
      - postgresql
    smtprelay:
      - mail
    repo:
      - http
