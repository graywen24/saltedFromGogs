containers:
  haproxy-a1:
    target: ctl-a1
    ip4: 100
    network:
      manage: {}
      ostack: {}
      ha: {}
    roles:
      - ostack
      - haproxy
  haproxy-a2:
    target: ctl-a2
    ip4: 101
    network:
      manage: {}
      ostack: {}
      ha: {}
    roles:
      - ostack
      - haproxy
  cdos-t1:
    target: ctl-a1
    ip4: 140
    network:
      manage: {}
      ostack: {}
    roles:
      - cdosalt
  cdos-a1:
    target: ctl-a1
    ip4: 102
    network:
      manage: {}
      ostack: {}
    roles:
      - cdos
      - cdosapp
  cdos-a2:
    target: ctl-a2
    ip4: 103
    network:
      manage: {}
      ostack: {}
    roles:
      - cdos
      - cdosapp
  horizon-a1:
    target: ctl-a1
    ip4: 104
    network:
      manage: {}
      ostack: {}
    packages:
      - ssl-cert
    roles:
      - ostack
      - horizon
  horizon-a2:
    target: ctl-a2
    ip4: 105
    network:
      manage: {}
      ostack: {}
    packages:
      - ssl-cert
    roles:
      - ostack
      - horizon
  glance-a1:
    target: ctl-a1
    ip4: 106
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - glance
  glance-a2:
    target: ctl-a2
    ip4: 107
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - glance
  cinder-a1:
    target: ctl-a1
    ip4: 108
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - cinder
  cinder-a2:
    target: ctl-a2
    ip4: 109
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - cinder
  nova-a1:
    target: ctl-a1
    ip4: 110
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - nova
  nova-a2:
    target: ctl-a2
    ip4: 111
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - nova
  keystone-a1:
    target: ctl-a1
    ip4: 112
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - keystone
  keystone-a2:
    target: ctl-a2
    ip4: 113
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - keystone
  cneutron-a1:
    target: ctl-a1
    ip4: 114
    common: ubuntu.lowsec.conf
    network:
      manage: {}
      ostack: {}
    packages:
      - iptables
    roles:
      - ostack
      - neutron
  cneutron-a2:
    target: ctl-a2
    ip4: 115
    common: ubuntu.lowsec.conf
    network:
      manage: {}
      ostack: {}
    packages:
      - iptables
    roles:
      - ostack
      - neutron
  ceilometer-a1:
    target: ctl-a1
    ip4: 116
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - ceilometer
  ceilometer-a2:
    target: ctl-a2
    ip4: 117
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - ceilometer
  cmd-a1:
    target: ctl-a1
    ip4: 118
    network:
      manage: {}
      ostack: {}
    roles:
      - cmd
      - juju
      - ostack
  cmd-a2:
    target: ctl-a2
    ip4: 119
    network:
      manage: {}
      ostack: {}
    roles:
      - cmd
      - juju
      - ostack
      - other
  bootstrap-a1:
    target: db-a1
    ip4: 120
    network:
      manage: {}
      ostack: {}
    roles:
      - juju
      - bootstrap
      - ostack
  bootstrap-a2:
    target: db-a2
    ip4: 121
    network:
      manage: {}
      ostack: {}
    roles:
      - juju
      - bootstrap
      - ostack
      - other
  bootstrap-a3:
    target: db-a3
    ip4: 139
    network:
      manage: {}
      ostack: {}
    roles:
      - juju
      - bootstrap
      - ostack
  percona-a1:
    target: db-a1
    ip4: 122
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - database
  percona-a2:
    target: db-a2
    ip4: 123
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - database
      - other
  percona-a3:
    target: db-a3
    ip4: 124
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - database
  cdosdb-t1:
    target: db-a1
    ip4: 141
    network:
      manage: {}
      ostack: {}
    roles:
      - database
      - cdosalt
  cdosdb-a1:
    target: db-a1
    active: False
    ip4: 125
    network:
      manage: {}
      ostack: {}
    roles:
      - database
      - cdos
  cdosdb-a2:
    target: db-a2
    active: False
    ip4: 126
    network:
      manage: {}
      ostack: {}
    roles:
      - database
      - cdos
  cdosdb-a3:
    target: db-a3
    active: False
    ip4: 127
    network:
      manage: {}
      ostack: {}
    roles:
      - database
      - cdos
  rabbitmq-a1:
    target: db-a1
    ip4: 128
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - messageq
  rabbitmq-a2:
    target: db-a2
    ip4: 129
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - messageq
  mongodb-a1:
    target: db-a1
    ip4: 130
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - database
  mongodb-a2:
    target: db-a2
    ip4: 131
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - database
  mongodb-a3:
    target: db-a3
    ip4: 132
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - database
  elasticsearch-a1:
    target: db-a1
    ip4: 133
    network:
      manage: {}
    roles:
      - elastic
  elasticsearch-a2:
    target: db-a2
    ip4: 134
    network:
      manage: {}
    roles:
      - elastic
  elasticsearch-a3:
    target: db-a3
    ip4: 135
    network:
      manage: {}
    roles:
      - elastic
  logstash-a1:
    target: db-a1
    ip4: 136
    network:
      manage: {}
    roles:
      - elastic
  logstash-a2:
    target: db-a2
    ip4: 137
    network:
      manage: {}
    roles:
      - elastic
  logstash-a3:
    target: db-a3
    ip4: 138
    network:
      manage: {}
    roles:
      - elastic
  cdos-a3:
    target: ctl-a3
    ip4: 142
    network:
      manage: {}
      ostack: {}
    roles:
      - cdos
      - cdosapp
  horizon-a3:
    target: ctl-a3
    ip4: 143
    network:
      manage: {}
      ostack: {}
    packages:
      - ssl-cert
    roles:
      - ostack
      - horizon
  glance-a3:
    target: ctl-a3
    ip4: 144
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - glance
  cinder-a3:
    target: ctl-a3
    ip4: 145
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - cinder
  nova-a3:
    target: ctl-a3
    ip4: 146
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - nova
  keystone-a3:
    target: ctl-a3
    ip4: 147
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - keystone
  ceilometer-a3:
    target: ctl-a3
    ip4: 148
    network:
      manage: {}
      ostack: {}
    roles:
      - ostack
      - ceilometer
  cmd-a3:
    target: ctl-a3
    ip4: 149
    network:
      manage: {}
      ostack: {}
    roles:
      - cmd
      - juju
      - ostack
  appcara-a1:
    target: ctl-a1
    ip4: 150
    network:
      manage: {}
      ostack: {}
    roles:
      - appcara
      - appcara_web
      - ostack
  appcara-a2:
    target: ctl-a2
    ip4: 151
    network:
      manage: {}
      ostack: {}
    roles:
      - appcara
      - appcara_web
      - ostack
  appcara-b1:
    target: ctl-a1
    ip4: 152
    network:
      manage: {}
      ostack: {}
    roles:
      - appcara
      - appcara_web
      - ostack
  appcara-b2:
    target: ctl-a2
    ip4: 153
    network:
      manage: {}
      ostack: {}
    roles:
      - appcara
      - appcara_web
      - ostack
  appcaradb-a1:
    target: db-a1
    ip4: 154
    network:
      manage: {}
    roles:
      - appcara
      - appcara_db
  appcaradb-a2:
    target: db-a2
    ip4: 155
    network:
      manage: {}
    roles:
      - appcara
      - appcara_db
  appcaradb-a3:
    target: db-a3
    ip4: 156
    network:
      manage: {}
    roles:
      - appcara
      - appcara_db
