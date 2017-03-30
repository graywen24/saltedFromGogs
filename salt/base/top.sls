base:
  '*':
    - core
    - debug.unlocked
    - sshd
  roles:host:
    - match: grain
    - core.grub
    - ntp
  roles:containerhost:
    - match: grain
    - containerhost
  'repo-a?.cde.1nc':
    - repo
  'micros-a1.cde.1nc':
    - bind
    - dhcpd
  'micros-a2.cde.1nc':
    - bind
  'ldap-a?.cde.1nc':
    - ldap.server
    - ldap.server.initial
  'lam-a?.cde.1nc':
    - lam
  'maas-a1.cde.1nc':
    - maas
  'cmd-a?.nhb.1nc':
    - juju.basics
    - juju.user
    - juju.debugcharm
  roles:elastic:
    - match: grain
    - elastic.install
    - elastic.configure
  roles:elastic_hq:
    - match: grain
    - elastic.install_plugin_hq
