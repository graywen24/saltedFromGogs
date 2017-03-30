
pwgen:
  pkg.installed: []

create_enlist_meta_script:
  file.managed:
  - name: /tmp/enlist.{{ pillar.enlist.domain }}.sh
  - source: salt://maas/files/scripts/enlist.sh
  - mode: 0775
  - user: root
  - group: root
  - template: jinja
  - require:
    - pkg: pwgen

{% if pillar.enlist.execute %}
{% set maaskey = salt.maas.key('root') %}

run_enlist_meta_script:
  cmd.run:
  - name: /tmp/enlist.{{ pillar.enlist.domain }}.sh
  - env:
    - MAAS_APIKEY: {{ maaskey }}
  - require:
    - file: create_enlist_meta_script

remove_enlist_meta_script:
  file.absent:
  - name: /tmp/enlist.{{ pillar.enlist.domain }}.sh
  - require:
    - cmd: run_enlist_meta_script

{% endif %}

