hosts:
  dev-node-01:
    ip4: 11
    partitions: partsmall
    network:
      console: {}
      manage:
        mac: 52:54:99:f8:0b:e5
    roles:
      - containerhost
    drivesets:
      - elastic
    mole: satellites
  dev-node-02:
    ip4: 12
    partitions: partsmall
    network:
      console: {}
      manage:
        mac: 52:54:99:90:77:52
    roles:
      - containerhost
    drivesets:
      - elastic
#    mole: satellites
  dev-node-03:
    ip4: 13
    partitions: partsmall
    network:
      console: {}
      manage:
        mac: 52:54:99:46:98:15
    roles:
      - containerhost
    drivesets:
      - elastic
#    mole: satellites
  dev-node-04:
    ip4: 14
    partitions: partsmall
    network:
      console: {}
      manage:
        mac: 52:54:99:91:f5:00
    roles:
      - containerhost
