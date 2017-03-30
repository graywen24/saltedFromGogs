defaults:
  saltenv: bbox
  nodebase:
    - /srv/nodebase/alchemy/hosts.sls
    - /srv/nodebase/alchemy/containers.sls
  maas:
    sub: hwe-v
    powertype: amt
    powerpass: Password1+
    zone: BBOX
    cluster: bbox
  dns:
    servers:
    - 172.21.48.103
    - 172.21.48.104
  ntp-servers:
    type: peer
    interfaces:
      first:
        main: br-mgmt
        fallback: eth2
    internal:
      ntp1.cde.1nc: 172.21.48.10
      ntp2.cde.1nc: 172.21.48.11
  network:
    console:
      domain: console.bbox.1nc
      ip4net: 10.14.4.{0}/24
    ostack:
      domain: ostack.bbox.1nc
      ip4net: 172.22.32.{0}/24
    manage:
      domain: bbox.1nc
      ip4net: 172.22.48.{0}/24
      routes:
        - name: cde_network
          ipaddr: 172.21.48.0
          netmask: 255.255.255.0
          gateway: 172.22.48.1
    storage:
      domain: store.bbox.1nc
      ip4net: 172.22.64.{0}/20
    ha:
      domain: ha.bbox.1nc
      ip4net: 192.168.100.{0}/24
  containers:
    network:
      common:
        macprefix: 02:aa:05
    mount:
      storage:
        local: /var/storage/{0}
        remote: var/storage
    lxcconf:
      lxc.start.auto: 1
      lxc.cgroup.devices.allow:
        allowmem: "c 1:1 rwm # allow reading /dev/mem :)"
    roles:
      - container
  templates:
    elastic:
      lxcconf:
        lxc.cgroup.memory.limit_in_bytes: 40G
        lxc.cgroup.memory.memsw.limit_in_bytes: 40G
      mount:
        sdb1:
          device: /dev/sdb1
          fs: ext4
          flags: defaults,noatime
          remote: var/lib/elasticsearch/sdb1
        sdc1:
          device: /dev/sdc1
          fs: ext4
          flags: defaults,noatime
          remote: var/lib/elasticsearch/sdc1
