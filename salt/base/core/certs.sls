
# here we handle the host specific certificates
{% for scope, details in salt.pillar.get('local:ssl', {}).iteritems() %}
{{ scope }}_cert:
  file.managed:
  - name: {{ pillar.defaults.ssl.basedir }}/{{ scope }}/{{ details.cert }}
  - source: salt://core/files/ssl/certs/{{ details.cert }}
  - mode: 0644
  - user: {{ details.get('user', 'root') }}
  - group: {{ details.get('group', 'root') }}
  - makedirs: True

{{ scope }}_cert_key:
  file.managed:
  - name: {{ pillar.defaults.ssl.basedir }}/{{ scope }}/{{ details.key }}
  - source: salt://core/files/ssl/certs/{{ details.key }}
  - mode: 0400
  - user: {{ details.get('user', 'root') }}
  - group: {{ details.get('group', 'root') }}
  - makedirs: True
{% endfor %}

