hosts:
  compute-a1:
    partitions: partbbox
    network:
      manage:
        mac: ec:a8:6b:fa:c8:45
  compute-a2:
    partitions: partbbox
    network:
      manage:
        mac: c0:3f:d5:6f:f3:a0
  ctl-a1:
    partitions: partbbox
    network:
      console:
        ip4: 15
      manage:
        mac: c0:3f:d5:6e:f9:0e
  ctl-a2:
    partitions: partbbox
    network:
      console:
        ip4: 16
      manage:
        mac: c0:3f:d5:6f:f3:5a
  db-a1:
    ip4: 14
    partitions: partbbox
    network:
      console:
        ip4: 17
      manage:
        mac: c0:3f:d5:6f:f3:be
  db-a2:
    partitions: partbbox
    network:
      console:
        ip4: 18
      manage:
        mac: c0:3f:d5:6f:f4:13
  db-a3:
    partitions: partbbox
    network:
      console:
        ip4: 19
      manage:
        mac: c0:3f:d5:6f:f3:76
  storage-a1:
    partitions: partbbox
    network:
      console:
        ip4: 12
      manage:
        mac: c0:3f:d5:6f:f2:ce
  storage-a2:
    partitions: partbbox
    network:
      console:
        ip4: 13
      manage:
        mac: c0:3f:d5:6f:f3:05
  storage-a3:
    partitions: partbbox
    network:
      console:
        ip4: 14
      manage:
        mac: c0:3f:d5:6f:f3:5d
