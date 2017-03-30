defaults:
  saltenv: vstage
  nodebase:
    - /srv/nodebase/alchemy/hosts.sls
    - /srv/nodebase/alchemy/containers.sls
  maas:
    key: ahV7Gcnb8GNdTGSvfD:EyshSE47PvcNWHDAcx:GRTUrmLaSSzx8FjCAZVU32vZPtpfzThs
    sub: hwe-v
    powertype: ipmi
    zone: VSTAGE
  dns:
    servers:
    - 10.1.48.103
    - 10.1.48.104
  ntp-servers:
    type: peer
    interfaces:
      first:
        main: br-mgmt
        fallback: eth2
    internal:
      ntp1.cde.1nc: 10.1.48.10
      ntp2.cde.1nc: 10.1.48.11
  network:
    console:
      domain: console.vstage.1nc
      ip4net: 10.0.16.{0}/20
    ostack:
      domain: ostack.vstage.1nc
      ip4net: 10.0.32.{0}/24
    manage:
      domain: vstage.1nc
      ip4net: 10.0.48.{0}/24
      postup: route add -net 10.1.48.0/20 gw 10.0.48.1
      gateway: 10.0.48.1
    storage:
      domain: store.vstage.1nc
      ip4net: 10.0.64.{0}/20
    ha:
      domain: ha.vstage.1nc
      ip4net: 192.168.100.{0}/24
  containers:
    network:
      common:
        macprefix: 02:aa:04
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
