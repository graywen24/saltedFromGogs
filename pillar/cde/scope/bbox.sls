stints:
  bootstrap:
    defaults:
      hostsfile:
        repo-a1.cde.1nc repo.cde.1nc repo-a1 repo: 172.21.48.10
      dns:
        servers: []
  small:
    defaults:
      dns:
        servers:
          - 172.21.48.103
defaults:
  bootfileserver: 172.21.48.100
  dns:
    servers:
      - 172.21.48.103
      - 172.21.48.104
    records:
      cde.1nc:
        - dns-a1,IN,A,172.21.48.103
        - dns-a2,IN,A,172.21.48.104
  ntp-servers:
    external:
      stdtime.gov.hk: 118.143.17.82
    internal:
      ntp1.cde.1nc: 172.21.48.10
      ntp2.cde.1nc: 172.21.48.11
  network:
    console:
      poweraddress: qemu+ssh://cloudadmin@192.168.168.1/system
    ostack:
      ip4net: 172.21.32.{0}/24
    manage:
      ip4net: 172.21.48.{0}/24
      gateway: 172.21.48.1
hosts:
  ess-a1:
    network:
      manage:
        mac: 52:54:00:bf:14:7b
  ess-a2:
    partitions: partbbox
    network:
      manage:
        mac: 44:a8:42:2e:7f:c2
containers:
  saltmaster-a1:
    mount:
      repo:
        local: /var/storage/{0}/saltstack
        remote: /var/storage/saltstack
maas:
  powertype: virsh
  powerpass: abc123
  cluster: bbox
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
