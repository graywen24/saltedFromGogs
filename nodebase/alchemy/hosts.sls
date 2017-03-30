hosts:
  compute-a1:
    ip4: 10
    partitions: partsmall
    network:
      console: {}
      manage:  {}
      ostack: {}
    roles:
      - ostack
  compute-a2:
    ip4: 11
    partitions: partsmall
    network:
      console: {}
      manage:  {}
      ostack: {}
    roles:
      - ostack
  ctl-a1:
    ip4: 12
    partitions: partbig
    network:
      console: {}
      manage:  {}
      ostack: {}
    packages:
      - vlan
    modules:
      - openvswitch
      - 8021q
      - ip_tables
      - xt_TPROXY
    roles:
      - containerhost
  ctl-a2:
    ip4: 13
    partitions: partbig
    network:
      console: {}
      manage:  {}
      ostack: {}
    packages:
      - vlan
    modules:
      - openvswitch
      - 8021q
      - ip_tables
      - xt_TPROXY
    roles:
      - containerhost
  db-a1:
    ip4: 14
    partitions: partbig
    network:
      console: {}
      manage:  {}
      ostack: {}
    drivesets:
      - elastic
    roles:
      - containerhost
#    mole: satellites
  db-a2:
    ip4: 15
    partitions: partbig
    network:
      console: {}
      manage:  {}
      ostack: {}
    drivesets:
      - elastic
    roles:
      - containerhost
#    mole: satellites
  db-a3:
    ip4: 16
    partitions: partbig
    network:
      console: {}
      manage:  {}
      ostack: {}
    drivesets:
      - elastic
    roles:
      - containerhost
    mole: satellites
  storage-a1:
    ip4: 17
    partitions: partsmall
    network:
      console: {}
      manage:  {}
      ostack: {}
      storage: {}
    roles:
      - ostack
  storage-a2:
    ip4: 18
    partitions: partsmall
    network:
      console: {}
      manage:  {}
      ostack: {}
      storage: {}
    roles:
      - ostack
  storage-a3:
    ip4: 19
    partitions: partsmall
    network:
      console: {}
      manage:  {}
      ostack: {}
      storage: {}
    roles:
      - ostack
  neutron-a1:
    ip4: 20
    network:
      console: {}
      manage:  {}
      ostack: {}
    packages:
      - iptables
    roles:
      - ostack
      - neutron
  neutron-a2:
    ip4: 21
    network:
      console: {}
      manage:  {}
      ostack: {}
    packages:
      - iptables
    roles:
      - ostack
      - neutron
  compute-a3:
    ip4: 22
    partitions: partsmall
    network:
      console: {}
      manage:  {}
      ostack: {}
    roles:
      - ostack
  compute-a4:
    ip4: 23
    partitions: partsmall
    network:
      console: {}
      manage:  {}
      ostack: {}
    roles:
      - ostack
  compute-b1:
    ip4: 24
    partitions: partsmall
    network:
      console: {}
      manage: {}
      ostack: {}
    roles:
      - ostack
  compute-b2:
    ip4: 25
    partitions: partsmall
    network:
      console: {}
      manage: {}
      ostack: {}
    roles:
      - ostack
  ctl-a3:
    ip4: 26
    partitions: partbig
    network:
      console: {}
      manage: {}
      ostack: {}
    packages:
      - vlan
    modules:
      - openvswitch
      - 8021q
      - ip_tables
      - xt_TPROXY
    roles:
      - containerhost
  neutron-a3:
    ip4: 27
    network:
      console: {}
      manage: {}
      ostack: {}
    packages:
      - iptables
    roles:
      - ostack
      - neutron
