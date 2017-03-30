{%- set hostpath = "hosts:%s:modules"|format(grains.nodename) %}
{%- set modules = salt['pillar.get'](hostpath, []) %}
{%- for module in modules %}

{{ module }}_insert_and_persist:
  kmod.present:
  - name: {{ module }}
  - persist: True

{%- endfor %}