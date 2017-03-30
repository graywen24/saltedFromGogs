
ca-certificates:
  pkg.installed: []

# this is only for public ssl certs & ca's
install_local_ca:
  file.recurse:
    - name: /usr/local/share/ca-certificates/cas
    - source: salt://core/files/ssl/ca
    - makedirs: True
    - clean: True
    - require:
      - pkg: ca-certificates

# Build chains from certs
{% for chain, certs in salt.pillar.get('defaults:ssl:chains', {}).iteritems() %}
install_chain_{{ chain }}:
  file.append:
    - name: {{ pillar.defaults.ssl.basedir }}/chains/{{ chain }}
    - sources: {{ certs }}
    - makedirs: True
    - require:
      - pkg: ca-certificates
{% endfor %}

update_certs:
  cmd.run:
    - name: update-ca-certificates
    - onchanges:
      - file: install_local_ca
