
# ensure this is only installed if the target has the correct role set
{% if 'elastic_hq' in grains.roles -%}

check_installed_hq:
  file.missing:
  - name: /usr/share/elasticsearch/plugins/hq

copy_hq:
  file.managed:
    - name: /tmp/elastic/ElasticHQ_v2.0.3.zip
    - source: salt://elastic/files/plugin/ElasticHQ_v2.0.3.zip
    - makedirs: True
    - require:
      - file: check_installed_hq

install_hq:
  cmd.run:
    - name: ./plugin install file:/tmp/elastic/ElasticHQ_v2.0.3.zip
    - cwd: /usr/share/elasticsearch/bin
    - require:
      - file: check_installed_hq

{% endif %}