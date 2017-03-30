icinga_api_config:
  file.managed:
  - name: /etc/icinga2/features-available/api.conf
  - source: salt://icinga/files/common/features/api.conf.tpl
  - template: jinja
  - watch_in:
    - service: icinga_service

icinga_graphite_config:
  file.managed:
  - name: /etc/icinga2/features-available/graphite.conf
  - source: salt://icinga/files/common/features/graphite.conf.tpl
  - template: jinja
  - watch_in:
    - service: icinga_service

{% for state, features in salt['icinga2.mole_features']().iteritems() -%}
# handle feature {{ state }}
{% if state == 'enabled' -%}
{% for feature in features -%}
icinga_{{ feature }}_feature:
  file.symlink:
  - name: /etc/icinga2/features-enabled/{{ feature }}.conf
  - target: /etc/icinga2/features-available/{{ feature }}.conf
  - watch_in:
    - service: icinga_service

{% endfor -%}
{% else -%}
{% for feature in features -%}
icinga_{{ feature }}_feature:
  file.absent:
  - name: /etc/icinga2/features-enabled/{{ feature }}.conf
  - watch_in:
    - service: icinga_service

{% endfor -%}
{% endif -%}
{% endfor -%}
