stints:
  bootstrap:
    defaults:
      hostsfile:
        repo-a1.cde.1nc repo.cde.1nc repo-a1 repo: 192.168.48.10
      dns:
        servers: []
  small:
    defaults:
      dns:
        servers:
          - 192.168.48.103
defaults:
  bootfileserver: 192.168.48.100
  dns:
    servers:
      - 192.168.48.103
      - 192.168.48.104
    records:
      cde.1nc:
        - dns-a1,IN,A,192.168.48.103
        - dns-a2,IN,A,192.168.48.104
  ntp-servers:
    external:
      stdtime.gov.hk: 118.143.17.82
    internal:
      ntp1.cde.1nc: 192.168.48.10
      ntp2.cde.1nc: 192.168.48.11
  network:
    console:
      poweraddress: qemu+ssh://cperz@192.168.48.1/system
    manage:
      ip4net: 192.168.48.{0}/24
      gateway: 192.168.48.1
    dev:
      ip4net: 192.168.122.{0}/24
hosts:
  ess-a1:
    network:
      dev:
        ip4: 22
        type: phys
        phys: eth1
        link: eth1
      manage:
        mac: 52:54:00:15:f6:5a
        phys: eth0
  ess-a2:
    partitions: partbbox
    network:
      dev:
        ip4: 23
        type: phys
        phys: eth1
        link: eth1
      manage:
        mac: 52:54:00:1a:d4:c5
        phys: eth0
containers:
  saltmaster-a1:
    active: False
  maas-a1:
    packages:
      - libvirt-bin
maas:
  powertype: virsh
  powerpass: maplin
  cluster: CDE
extras:
  repo:
    aliases:
      - /testing /var/www/repos/alchemy/testing
      - /stable /var/www/repos/alchemy/stable
mail:
  smarthost:
    relayed_networks: 192.168.48.0/24, 192.168.68.0/24
    upstream_relay: ""
    catchall: True

