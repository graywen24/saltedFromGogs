

edit_rules:
  file.replace:
    - name: /etc/udev/rules.d/70-persistent-net.rules
    - pattern: eth0
    - repl: eth2

edit_interfaces:
  file.replace:
    - name: /etc/network/interfaces
    - pattern: eth0
    - repl: eth2

doreboot:
  cmd.run:
    - name: reboot
    - onchanges:
      - file: edit_rules
      - file: edit_interfaces