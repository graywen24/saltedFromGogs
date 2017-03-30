defaults:
  saltenv: dev
  maas:
    powertype: virsh
    powerpass: maplin
    cluster: CDE
    sub: hwe-v
    zone: DEV
  dns:
    servers:
    - 192.168.48.103
    - 192.168.48.104
  ntp-servers:
    type: peer
    interfaces:
      first:
        main: br-mgmt
        fallback: eth0
    internal:
      ntp1.cde.1nc: 192.168.48.10
      ntp2.cde.1nc: 192.168.48.11
  network:
    console:
      poweraddress: qemu+ssh://cperz@192.168.48.1/system
      domain: console.dev.1nc
      ip4net: 192.168.88.{0}/24
    ostack:
      domain: ostack.dev.1nc
      ip4net: 192.168.78.{0}/24
    manage:
      domain: dev.1nc
      ip4net: 192.168.68.{0}/24
      routes:
        - name: cde_network
          ipaddr: 192.168.48.0
          netmask: 255.255.255.0
          gateway: 192.168.68.1
  hosts:
    network:
      manage:
        phys: eth0
  containers:
    network:
      common:
        macprefix: 02:aa:03
    mount:
      storage:
        local: /var/storage/{0}
        remote: /var/storage
    lxcconf:
      lxc.start.auto: 1
      lxc.cgroup.devices.allow:
        allowmem: "c 1:1 rwm # allow reading /dev/mem :)"
    roles:
      - container
  templates:
    elastic:
      lxcconf:
        lxc.cgroup.memory.limit_in_bytes: 4G
        lxc.cgroup.memory.memsw.limit_in_bytes: 4G
      mount:
        vdb1:
          device: /dev/vdb1
          fs: ext4
          flags: defaults,noatime
          remote: var/lib/elasticsearch/vdb1
        vdc1:
          device: /dev/vdc1
          fs: ext4
          flags: defaults,noatime
          remote: var/lib/elasticsearch/vdc1
        vdd1:
          device: /dev/vdd1
          fs: ext4
          flags: defaults,noatime
          remote: var/lib/elasticsearch/vdd1
