
qicingaweb2_php_timezone:
  file.managed:
  - contents: |
      ; Defines the default timezone used by the date functions
      ; http://php.net/date.timezone
      date.timezone="{{ pillar.defaults.timezone }}"
  - name: /etc/php5/mods-available/timezone.ini
  - watch_in:
    - service: icingaweb2_apache_running

icingaweb2_php_timezone_activate:
  file.symlink:
  - name: /etc/php5/apache2/conf.d/30-timezone.ini
  - target: /etc/php5/mods-available/timezone.ini
  - watch_in:
    - service: icingaweb2_apache_running

www-data:
  user.present:
  - groups:
    - nagios
  - watch_in:
    - service: icingaweb2_apache_running

ensure_owner:
  file.directory:
    - name: /etc/icingaweb2
    - user: www-data
    - group: icingaweb2
    - require:
      - user: www-data
    - recurse:
      - user
      - group

icingaweb2_configuration:
  file.recurse:
  - name: /etc/icingaweb2
  - source: salt://icinga/web/files
  - user: www-data
  - group: icingaweb2
  - template: jinja
  - require:
    - file: ensure_owner
  - watch_in:
    - service: icingaweb2_apache_running

{% for module, enabled in salt['pillar.get']('icinga:web:modules', {}).iteritems() -%}
# handle module {{ module }}
{% if enabled -%}
icingaweb_{{ module }}_module:
  file.symlink:
  - name: /etc/icingaweb2/enabledModules/{{ module }}
  - target: /usr/share/icingaweb2/modules/{{ module }}
  - user: www-data
  - group: icingaweb2
  - makedirs: True
  - require:
    - file: icingaweb2_configuration
  - watch_in:
    - service: icingaweb2_apache_running

{% else -%}
icingaweb2_{{ module }}_module:
  file.absent:
  - name: /etc/icingaweb2/enabledModules/{{ module }}
  - watch_in:
    - service: icingaweb2_apache_running

{% endif -%}
{% endfor -%}

icingaweb_config_disable:
  file.managed:
  - name: /etc/apache2/conf-available/icingaweb2.conf
  - source: salt://icinga/web/files/apache/icingaweb2.conf
  - watch_in:
    - service: icingaweb2_apache_running

icingaweb_default_host:
  file.managed:
  - name: /etc/apache2/sites-available/000-default.conf
  - source: salt://icinga/web/files/apache/default.conf
  - watch_in:
    - service: icingaweb2_apache_running

icingaweb2_apache_running:
  service.running:
  - name: apache2

