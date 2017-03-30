containers:
  elasticsearch-a1:
    target: dev-node-01
    ip4: 133
    template: elastic
    network:
      manage: {}
    roles:
      - elastic
      - elastic_master
      - elastic_data
      - elastic_hq
  elasticsearch-a2:
    target: dev-node-02
    ip4: 134
    template: elastic
    network:
      manage: {}
    roles:
      - elastic
      - elastic_master
      - elastic_data
  elasticsearch-a3:
    target: dev-node-03
    ip4: 135
    template: elastic
    network:
      manage: {}
    roles:
      - elastic
      - elastic_master
      - elastic_data
  logstash-a1:
    target: dev-node-01
    ip4: 136
    network:
      manage: {}
    roles:
      - logstash
  logstash-a2:
    target: dev-node-02
    ip4: 137
    network:
      manage: {}
    roles:
      - logstash
  logstash-a3:
    target: dev-node-03
    ip4: 138
    network:
      manage: {}
    roles:
      - logstash
