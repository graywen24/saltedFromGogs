
apache2:
  pkg.installed: []

apache_config:
  file.managed:
  - name: /etc/apache2/sites-available/lam.conf
  - source: salt://lam/files/apache/lam.conf
  - template: jinja

default_disabled:
  file.absent:
  - name: /etc/apache2/sites-enabled/000-default.conf

has_rewrite:
  apache_module.enable:
  - name: rewrite

ensure_enabled:
  file.symlink:
  - name: /etc/apache2/sites-enabled/lam.conf
  - target: /etc/apache2/sites-available/lam.conf
  - require:
    - file: default_disabled

apache_running:
  service.running:
  - name: apache2
  - watch:
    - file: apache_config
    - file: ensure_enabled
    - apache_module: has_rewrite
  - require:
    - pkg: alchemy-ldap-manager
