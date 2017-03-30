
install_banner:
  file.managed:
  - name: /etc/issue
  - source: salt://core/files/issue.banner
  - mode: 0644

