group_cas:
  group.present:
  - name: cas
  - gid: 500

group_ops:
  group.present:
  - name: ops
  - gid: 501

group_csc:
  group.present:
  - name: csc
  - gid: 502

update_sudoers:
  file.managed:
  - name: /etc/sudoers
  - source: salt://core/files/sudoers
  - mode: 440

install_sudoers_snippets:
  file.recurse:
  - name: /etc/sudoers.d
  - source: salt://core/files/sudoers.d
  - file_mode: 440
  - clean: true
