
isc-dhcp-server:
  pkg.purged: []

no_config:
  file.absent:
  - name: /etc/dhcp/dhcpd.subnets.conf

no_subnet_configs:
  file.absent:
  - name: /etc/dhcp/subnets

