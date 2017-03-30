defaults:
  saltenv: cde
  nodebase:
    - /srv/nodebase/cde/hosts.sls
    - /srv/nodebase/cde/containers.sls
  bootfileserver: 10.1.48.100
  dns:
    servers:
      - 10.1.48.103
      - 10.1.48.104
    records:
      cde.1nc:
        - dns-a1,IN,A,10.1.48.103
        - dns-a2,IN,A,10.1.48.104
  ntp-servers:
    type: server
    interfaces:
      first:
        main: br-mgmt
        fallback: eth2
    external:
      stdtime.gov.hk: 118.143.17.82
      time.hko.hk: 223.255.185.2
      ntp.nict.jp: 133.243.238.243
      time.nist.gov: 24.56.178.140
    internal:
      ntp1.cde.1nc: 10.1.48.10
      ntp2.cde.1nc: 10.1.48.11
  network:
    console:
      domain: console.cde.1nc
      ip4net: 10.1.16.{0}/20
    ostack:
      domain: ostack.cde.1nc
      ip4net: 10.1.32.{0}/20
    manage:
      domain: cde.1nc
      ip4net: 10.1.48.{0}/20
      gateway: 10.1.48.1
  hosts:
    roles:
      - metal
  containers:
    network:
      common:
        macprefix: 02:aa:01
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
