
icingaweb2_module_enable:
  file.symlink:
  - name: /etc/icingaweb2/enabledModules/graphite
  - target: /usr/share/icingaweb2/modules/graphite
  - user: www-data
  - group: icingaweb2
  - makedirs: True
  - watch_in:
    - service: apache2_service

icingaweb2_module_config:
  file.managed:
  - name: /etc/icingaweb2/modules/graphite/config.ini
  - source: salt://icinga/graphite/files/config/web2_config.ini
  - user: www-data
  - group: icingaweb2
  - template: jinja
  - makedirs: True

carboncache_config:
  file.managed:
  - name: /etc/carbon/carbon.conf
  - source: salt://icinga/graphite/files/config/carbon_cache.conf
  - makedirs: True
  - template: jinja
  - watch_in:
    - service: carbon_cache_service

carboncache_storage:
  file.managed:
  - name: /etc/carbon/storage-schemas.conf
  - source: salt://icinga/graphite/files/config/carbon_storage-schemas.conf
  - makedirs: True
  - template: jinja
  - watch_in:
    - service: carbon_cache_service

carboncache_enabled:
  file.replace:
  - name: /etc/default/graphite-carbon
  - pattern: CARBON_CACHE_ENABLED=false
  - repl: CARBON_CACHE_ENABLED=true
  - watch_in:
    - service: carbon_cache_service

carbon_cache_service:
  service.running:
  - name: carbon-cache

graphite_settings:
  file.managed:
  - name: /etc/graphite/local_settings.py
  - source: salt://icinga/graphite/files/config/graphite_local_settings.py
  - template: jinja
  - makedirs: True
  - watch_in:
    - service: apache2_service

{% if 'icinga_db_master' in grains.roles %}
has_graphite_tables:
  cmd.run:
    - name: python /usr/lib/python2.7/dist-packages/graphite/manage.py syncdb --noinput
    - require:
      - file: graphite_settings
{% endif %}

graphite_apache:
  file.managed:
  - name: /etc/apache2/sites-available/graphite.conf
  - source: salt://icinga/graphite/files/config/apache2.graphite.conf
  - template: jinja
  - makedirs: True
  - watch_in:
    - service: apache2_service

graphite_apache_enabled:
  file.symlink:
  - name: /etc/apache2/sites-enabled/graphite.conf
  - target: /etc/apache2/sites-available/graphite.conf
  - require:
    - file: graphite_apache
  - watch_in:
    - service: apache2_service

graphite_apache_port:
  file.managed:
  - name: /etc/apache2/conf-available/graphite.port.conf
  - source: salt://icinga/graphite/files/config/apache2.graphite.port.conf
  - template: jinja
  - makedirs: True
  - watch_in:
    - service: apache2_service

graphite_apache_port_enabled:
  file.symlink:
  - name: /etc/apache2/conf-enabled/graphite.port.conf
  - target: /etc/apache2/conf-available/graphite.port.conf
  - require:
    - file: graphite_apache_port
  - watch_in:
    - service: apache2_service

apache2_service:
  service.running:
  - name: apache2