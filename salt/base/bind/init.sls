
bind9:
  pkg.latest: []

# set default options for bind server
bind_server_options:
  file.replace:
  - name: /etc/default/bind9
  - pattern: ^OPTIONS=.*
  - repl: OPTIONS="-4 -u bind"

# files provied and managed by the
bind_keys:
  file.exists:
  - name: /etc/bind/bind.keys

# Ensure directories
zone_dir:
  file.directory:
  - name: /etc/bind/zones/zone
  - makedirs: True

arpa_dir:
  file.directory:
  - name: /etc/bind/zones/arpa
  - makedirs: True

zone_conf_dir:
  file.directory:
  - name: /etc/bind/zones/conf
  - makedirs: True

# Ensure named.zones.conf exists
named_zones_config:
  file.managed:
  - name: /etc/bind/zones/named.zones.conf
  - replace: False

configs:
  file.recurse:
    - name: /etc/bind
    - source: salt://bind/files/config
    - exclude_pat: E@(^zones$)|(^zones\/.*)|(^bind.keys$)
    - template: jinja
    - clean: True
    - user: root
    - group: root
    - dir_mode: 0775
    - file_mode: 0644
    - include_empty: True
    - require:
      - file: bind_keys

bind9_refresh:
  service.running:
    - name: bind9
    - sig: /usr/sbin/named
    - watch:
      - file: configs
      - file: bind_server_options
