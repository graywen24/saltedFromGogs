
{% for zone, zonedata in pillar.zones.iteritems() %}

{% set type = pillar.soa[zone].get('type', 'zone') %}
{% set serial = pillar.soa[zone].get('serial', 0) %}

{{ zone }}_file:
  file.managed:
  - name: /etc/bind/zones/{{ type }}/{{ zone }}.db
  - source: salt://bind/files/templates/{{ type }}.tpl
  - template: jinja
  - makedirs: True
  - context:
      zone: {{ zone }}
  - watch_in:
    - service: bind9_service
    - file: named_zones_include

{{ zone }}_soa_file:
  file.managed:
  - name: /etc/bind/zones/{{ type }}/{{ zone }}.soa.db
  - source: salt://bind/files/templates/soa.tpl
  - template: jinja
  - makedirs: True
  - context:
      zone: {{ zone }}
      serial: {{ serial }}
  - onchanges:
    - file: {{ zone }}_file
  - watch_in:
    - service: bind9_service
    - file: named_zones_include

{{ zone }}_config_file:
  file.managed:
  - name: /etc/bind/zones/conf/{{ zone }}.conf
  - source: salt://bind/files/templates/conf.tpl
  - template: jinja
  - makedirs: True
  - context:
      zone: {{ zone }}
      type: {{ type }}
  - watch_in:
    - service: bind9_service
    - file: named_zones_include

{% endfor %}

named_zones_include:
  file.managed:
  - name: /etc/bind/zones/named.zones.conf
  - source: salt://bind/files/templates/zones.conf.tpl
  - template: jinja

bind9_service:
  service.running:
  - name: bind9
  - sig: /usr/sbin/named
  - require:
    - file: named_zones_include