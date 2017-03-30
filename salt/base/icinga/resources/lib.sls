
# dont have conf file for zones
icinga_no_zonesconf:
  file.absent:
  - name: /etc/icinga2/zones.conf
  - watch_in:
    - service: icinga_service


master_global_zone_configured:
  file.managed:
  - name: /etc/icinga2/zones.conf.d/globals.conf
  - makedirs: True
  - contents: |
      /*
       * {{ pillar.defaults.hint }}
       */

      object Zone "globals" { global = true }

  - watch_in:
    - service: icinga_service


# create the zone file structure for a master
{% set active_envs = salt.pillar.get('saltenv:active', {}) -%}
{% for environment, _ in active_envs.iteritems() -%}

#{{ environment }}_zones_configured:
#  file.managed:
#  - name: /etc/icinga2/zones.conf.d/{{ environment }}.conf
#  - source: salt://icinga/files/cluster/zones.conf.tpl
#  - template: jinja
#  - makedirs: True
#  - contexts:
#    environment: {{ environment }}
#  - watch_in:
#    - service: icinga_service

{% endfor %}
