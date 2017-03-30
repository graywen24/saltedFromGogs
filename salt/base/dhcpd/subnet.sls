
{% set data = salt.pillar.get('dhcpd', {}) %}
{% set subnet = salt.pillar.get('dhcpd:subnet:group', 'unknown') %}

{{ subnet }}_file:
  file.managed:
  - name: /etc/dhcp/subnets/{{ subnet }}.conf
  - source: salt://dhcpd/files/subnet.conf.tpl
  - template: jinja
  - makedirs: True
  - context:
      data: {{ data }}
  - watch_in:
    - file: dhcpd_subnets_config
    - service: dhcpd_service

dhcpd_subnets_config:
  file.managed:
  - name: /etc/dhcp/dhcpd.subnets.conf
  - source: salt://dhcpd/files/subnets.conf.tpl
  - template: jinja
  - watch_in:
    - service: dhcpd_service

dhcpd_service:
  service.running:
    - name: isc-dhcp-server
    - sig: dhcpd
    - require:
      - file: dhcpd_subnets_config
