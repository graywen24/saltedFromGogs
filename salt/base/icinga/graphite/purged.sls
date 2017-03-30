
{% if 'icinga_db_master' in grains.roles %}
drop_db:
  cmd.run:
    - name: mysql -u {{ pillar.icinga.mysql.dbuser }} -e 'drop database graphite;'
    - env:
      - MYSQL_PWD: '{{ pillar.icinga.mysql.dbpass }}'
      - MYSQL_HOST: '{{ pillar.icinga.mysql.dbhost }}'
{% endif %}

icinga2_graphite_packages:
  pkg.purged:
  - pkgs:
    - libapache2-mod-wsgi
    - graphite-web
    - graphite-carbon

icingaweb2_graphite_packages_autopurged:
  cmd.run:
  - name: apt-get autoremove --purge -y --force-yes

icingaweb2_graphite_module:
  file.absent:
  - name: /usr/share/icingaweb2/modules/graphite

carboncache_config:
  file.absent:
  - name: /etc/carbon

carboncache_default:
  file.absent:
  - name: /etc/default/graphite-carbon

graphite_config:
  file.absent:
  - name: /etc/graphite

graphite_apache:
  file.absent:
  - name: /etc/apache2/sites-available/graphite.conf

graphite_apache_enabled:
  file.absent:
  - name: /etc/apache2/sites-enabled/graphite.conf

graphite_apache_port:
  file.absent:
  - name: /etc/apache2/conf-available/graphite.port.conf

graphite_apache_port_enabled:
  file.absent:
  - name: /etc/apache2/conf-enabled/graphite.port.conf

