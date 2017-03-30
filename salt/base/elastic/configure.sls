
# ensure all data folders are owned by the elasticsearch user
{% set config = salt['alchemy.elastic']() %}
{% for dir in config.data_dirs %}

{{ dir }}_ownermode:
  file.directory:
    - name: {{ dir }}
    - makedirs: False
    - user: {{ config.user }}
    - group: {{ config.group }}
    - dir_mode: 0775
    - require_in:
      - file: elastic_defaults
      - file: elastic_config

{% endfor %}

elastic_management:
  file.recurse:
    - name: /usr/share/emanage/
    - source: salt://elastic/files/tools

elastic_management_command_mode:
  file.symlink:
  - name: /usr/share/emanage/emanage
  - mode: 0755

elastic_management_command:
  file.symlink:
  - name: /usr/bin/emanage
  - target: /usr/share/emanage/emanage

elastic_defaults:
  file.managed:
    - name: /etc/default/elasticsearch
    - source: salt://elastic/files/elastic.default
    - template: jinja

elastic_config:
  file.managed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - source: salt://elastic/files/elasticsearch.yml
    - template: jinja

elastic_logging:
  file.managed:
    - name: /etc/elasticsearch/logging.yml
    - source: salt://elastic/files/logging.yml
    - template: jinja

elastic_service:
  service.running:
    - name: elasticsearch
    - watch:
      - file: elastic_defaults
      - file: elastic_config
      - file: elastic_logging

