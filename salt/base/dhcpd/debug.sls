
syslogconfig:
  file.managed:
    - name: /etc/rsyslog.d/90-dhcplog.conf
    - source: salt://dhcpd/files/90-dhcplog.conf

restart:
  service.running:
    - name: rsyslog
    - watch:
      - file: syslogconfig

