defaults:
  hint: This file is managed by salt - do not edit localy, changes will be overwritten.
  bashtimeout: 9000
  timezone: Asia/Singapore
  assemble: True
  lxc:
    profile: ubuntu
    sysconfig: ubuntu.common.conf
  salt:
    url: http://repo.cde.1nc/salt/install_salt.sh
    version: 2015.5.11+ds-1
  dns:
    records:
      default:
        - "@,IN,NS,dns-a1.cde.1nc."
        - "@,IN,NS,dns-a2.cde.1nc."
  ssl:
    basedir: /etc/ssl
    chains:
      CAS.client.chain.crt:
        - salt://core/files/ssl/ca/CAS.client.issuerCA.crt
        - salt://core/files/ssl/ca/1-NetCA.crt
      CAS.service.chain.crt:
        - salt://core/files/ssl/ca/CAS.service.issuerCA.crt
        - salt://core/files/ssl/ca/1-NetCA.crt
  hostsfile:
    ess-a1.cde.1nc ess-a1 salt.cde.1nc salt: 10.1.48.10
    repo-a1.cde.1nc repo.cde.1nc repo-a1 repo: 10.1.48.101
    micros-a1.cde.1nc micros-a1: 10.1.48.103
    ldap-a1.cde.1nc: 10.1.48.108
    ldap-a2.cde.1nc: 10.1.48.111
  network:
    common: {}
    console:
      configure: False
    manage: {}
    ostack: {}
    storage: {}
    ha: {}
  hosts:
    network:
      console: {}
      manage:
        type: bridge
        link: br-mgmt
        phys: eth2
      ostack:
        type: bond
        link: br-stack
        phys: bond0
        bond:
         - eth0
         - eth1
      storage:
        type: bond
        link: br-store
        phys: bond1
        bond:
         - eth4
         - eth5
      ha:
        type: bridge
        link: br-ha
        phys: eth3
    roles:
      - baseline
      - metal
      - host
  containers:
    bootstrap: 1
    network:
      common:
        type: veth
        flags: up
        macprefix: 02:aa:00
        mac: auto
      manage:
        name: eth0
        link: br-mgmt
        vpref: vma
      ostack:
        name: eth1
        link: br-stack
        vpref: vos
      storage:
        name: eth2
        link: br-store
        vpref: vst
      ha:
        name: eth4
        link: br-ha
        vpref: vha
    mount:
      storage:
        local: /var/storage/{0}
        remote: /var/storage
    lxcconf:
      lxc.start.auto: 1
      lxc.cgroup.devices.allow:
        allowmem: "c 1:1 rwm # allow reading /dev/mem :)"
    roles:
      - baseline
      - container
