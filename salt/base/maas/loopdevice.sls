
loop_control:
  file.mknod:
    - name: /dev/loop-control
    - ntype: c
    - major: 10
    - minor: 237
    - user: root
    - group: root
    - mode: 600

loop_device:
  file.mknod:
    - name: /dev/loop0
    - ntype: b
    - major: 7
    - minor: 0
    - user: root
    - group: disk
    - mode: 660

