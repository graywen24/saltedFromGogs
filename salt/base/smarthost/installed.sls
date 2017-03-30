{%- set catchall = salt.pillar.get('catchall', False) %}

postfix:
  pkg.latest: []

postfix_configure:
  file.managed:
  - name: /etc/postfix/main.cf
  - source: salt://smarthost/files/main.cf
  - template: jinja

postfix_reloaded:
  service.running:
  - name: postfix
  - watch:
    - file: postfix_configure

{%- if catchall %}
postfix_catch_all:
  file.managed:
  - name: /etc/postfix/catch_all
  - contents: /^.*$/ ubuntu
{%- endif %}
