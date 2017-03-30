containers:
  haproxy-a1:
    network:
      ha:
        gateway: 192.168.100.1
  haproxy-a2:
    network:
      ha:
        gateway: 192.168.100.1
  cdos-a1: {}
  cdos-a2: {}
  horizon-a1: {}
  horizon-a2: {}
  glance-a1: {}
  glance-a2: {}
  cinder-a1: {}
  cinder-a2: {}
  nova-a1: {}
  nova-a2: {}
  keystone-a1: {}
  keystone-a2: {}
  cneutron-a1: {}
  cneutron-a2: {}
  ceilometer-a1: {}
  ceilometer-a2: {}
  cmd-a1: {}
  cmd-a2: {}
  bootstrap-a1: {}
  bootstrap-a2: {}
  bootstrap-a3: {}
  percona-a1: {}
  percona-a2: {}
  percona-a3: {}
  cdosdb-a1: {}
  cdosdb-a2: {}
  cdosdb-a3: {}
  rabbitmq-a1: {}
  rabbitmq-a2: {}
  mongodb-a1: {}
  mongodb-a2: {}
  mongodb-a3: {}
  elasticsearch-a1: {}
  elasticsearch-a2: {}
  elasticsearch-a3: {}
  logstash-a1: {}
  logstash-a2: {}
  logstash-a3: {}
  appcara-a1: {}
  appcara-a2: {}
  appcara-b1: {}
  appcara-b2: {}
  appcaradb-a1: {}
  appcaradb-a2: {}
  appcaradb-a3: {}
