plugins_installed:
  file.recurse:
  - name: {{ pillar.monitor.plugindir }}
  - source: salt://icinga/files/common/plugins
  - makedirs: True
  - clean: True
  - template: jinja
  - user: root
  - group: root
  - dir_mode: 0755
  - file_mode: 0755
