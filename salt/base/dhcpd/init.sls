
isc-dhcp-server:
  pkg.latest: []

dhcpd.conf:
  file.managed:
    - name: /etc/dhcp/dhcpd.conf
    - source: salt://dhcpd/files/dhcpd.conf
    - template: jinja
    - user: root
    - mode: 644

# Ensure dhcpd.subnets.conf exists
dhcpd_subnets_config:
  file.managed:
  - name: /etc/dhcp/dhcpd.subnets.conf
  - replace: False

dhcpd:
  service.running:
    - name: isc-dhcp-server
    - sig: dhcpd
    - watch:
      - file: dhcpd.conf
