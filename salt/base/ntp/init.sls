# install an maintain ntp server on the target host

ntp:
  pkg.latest: []

ntpconfig:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://ntp/files/ntp.conf
    - template: jinja

serverwatch:
  service.running:
    - name: ntp
    - sig: ntpd
    - watch:
      - file: ntpconfig
