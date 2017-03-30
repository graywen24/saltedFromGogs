
syslogconfig:
  file.absent:
    - name: /etc/rsyslog.d/90-dhcplog.conf

dhcpdlog:
  file.absent:
    - name: /var/log/dhcpd.log

restart:
  service.running:
    - name: rsyslog
    - watch:
      - file: syslogconfig
      - file: dhcpdlog

