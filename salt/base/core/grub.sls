
# On all machines with the role host, install a
# grub defaults file and rebuild grub
# TODO: Add a hint to reboot the machine after this

{% if 'host' in grains.roles %}

default_grub:
  file.managed:
    - name: /etc/default/grub
    - source: salt://core/files/grub.default
    - template: jinja

rebuild_grub:
  cmd.run:
    - name: /usr/sbin/update-grub
    - onchanges:
      - file: default_grub

{% endif %}