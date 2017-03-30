
resolvconf:
  pkg.purged: []

updateresolver:
  file.managed:
    - name: /etc/resolv.conf
    - source: salt://core/files/resolv.conf
    - template: jinja
