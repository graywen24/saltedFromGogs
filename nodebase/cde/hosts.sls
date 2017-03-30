hosts:
  ess-a1:
    ip4: 10
    partitions: partbig
    no_maas: True
    network:
      console: {}
      manage:
        mac: 44:A8:42:2E:7F:DA
    roles:
      - seed
      - containerhost
      - ntp
  ess-a2:
    ip4: 11
    partitions: partbig
    network:
      console: {}
      manage:
        mac: 44:A8:42:2E:7F:C2
    roles:
      - containerhost
      - ntp
  ess-a3:
    ip4: 12
    partitions: partbig
    no_maas: True
    network:
      console: {}
      manage:
        mac: 44:A8:42:2E:74:CE
    roles:
      - containerhost
      - ntp
  ess-a4:
    ip4: 13
    partitions: partbig
    no_maas: True
    network:
      console: {}
      manage:
        mac: 44:A8:42:2E:74:F2
    roles:
      - containerhost
      - ntp
