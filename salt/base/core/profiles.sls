
enable_autologout:
  file.managed:
  - name: /etc/profile.d/autologout.sh
  - source: salt://core/files/profile/autologout.sh
  - template: jinja
  - mode: 775