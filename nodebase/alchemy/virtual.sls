virtual:
  vneutron-a1:
    target: ctl-a1
    ip4: 40
    partitions: partsmall
    network:
      manage:
        mac: 52:54:02:80:2C:B4
      ostack: {}
      storage: {}
    kvm:
      name: ubu-vneutron-a1
      uuid: 30de3ba6-331e-4b13-9a7e-8f3f4fdc5f81
      vcpu: 2
      memory: 2097152
      disk:
        image: /var/storage/local/images/vneutron-a1.img
        size: 20G
        format: qcow2
      macs:
        ostack: 52:54:02:57:87:9C
        nhb: 52:54:02:1A:78:BD
    roles:
      - ostack
  vneutron-a2:
    target: ctl-a2
    ip4: 41
    partitions: partsmall
    network:
      manage:
        mac: 52:54:02:51:57:DE
      ostack: {}
      storage: {}
    kvm:
      name: ubu-vneutron-a2
      uuid: 7d69db77-99b7-4dde-a656-5d41b818469b
      vcpu: 2
      memory: 2097152
      disk:
        image: /var/storage/local/images/vneutron-a2.img
        size: 20G
        format: qcow2
      macs:
        ostack: 52:54:02:FA:24:5C
        nhb: 52:54:02:AE:89:D4
    roles:
      - ostack
