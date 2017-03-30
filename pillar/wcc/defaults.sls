defaults:
  saltenv: wcc
  nodebase:
    - /srv/nodebase/alchemy/hosts.sls
    - /srv/nodebase/alchemy/containers.sls
  maas:
    key: ahV7Gcnb8GNdTGSvfD:EyshSE47PvcNWHDAcx:GRTUrmLaSSzx8FjCAZVU32vZPtpfzThs
    sub: hwe-v
    powertype: ipmi
    zone: WCC
  dns:
    servers:
    - 10.1.48.103
    - 10.1.48.104
    origin:
      reverse: 3.10.in-addr.arpa
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
    schema: racked
    console:
      domain: console.wcc.1nc
      ip4net:
        rack01: 10.3.16.{0}/22
        rack02: 10.3.17.{0}/22
        rack03: 10.3.18.{0}/22
    manage:
      domain: wcc.1nc
      gateway: 10.3.48.1
      postup: route add -net 10.1.48.0/20 gw 10.3.48.1
      ip4net:
        rack01: 10.3.48.{0}/22
        rack02: 10.3.49.{0}/22
        rack03: 10.3.50.{0}/22
    ostack:
      domain: ostack.wcc.1nc
      ip4net:
        rack01: 10.3.32.{0}/22
        rack02: 10.3.33.{0}/22
        rack03: 10.3.34.{0}/22
    storage:
      domain: store.wcc.1nc
      ip4net:
        rack01: 10.3.64.{0}/22
        rack02: 10.3.65.{0}/22
        rack03: 10.3.66.{0}/22
    ha:
      domain: ha.wcc.1nc
      ip4net: 192.168.103.{0}/24
  hosts:
    network:
      manage:
         postup: route add -net 10.1.48.0/20 gw 10.3.48.1
         gateway: 10.3.48.1
  containers:
    network:
      common:
        type: veth
        flags: up
        macprefix: 02:aa:06
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
