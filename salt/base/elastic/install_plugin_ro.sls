
copy_ro:
  file.managed:
    - name: /tmp/elastic/elasticsearch-readonlyrest-v1.5_es-v2.1.1.zip
    - source: salt://elastic/files/plugin/elasticsearch-readonlyrest-v1.5_es-v2.1.1.zip
    - makedirs: true

install_ro:
  cmd.run:
    - name: ./plugin install file:/tmp/elastic/elasticsearch-readonlyrest-v1.5_es-v2.1.1.zip
    - cwd: /usr/share/elasticsearch/bin
