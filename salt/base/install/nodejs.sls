
{% set version = 'v0.10.35' %}
{% set versiondir = 'node-'+version+'-linux-x64' %}

extract_node:
  archive.extracted:
  - name: /usr/lib/node/
  - source: http://repo.cde.1nc/files/node-{{version}}-linux-x64.forever.grunt.tar.gz
  - source_hash: md5=8eebb08884330a4511aeb31d40689d5f
  - archive_format: tar
  - if_missing: /usr/lib/node/{{ versiondir }}

set_node_profile:
  file.managed:
  - name: /etc/profile.d/node.sh
  - contents: |
      export NODE_HOME=/usr/lib/node/{{ versiondir }}
      export PATH=$NODE_HOME/bin:$PATH
  - mode: 0775
  - user: root
  - group: root
