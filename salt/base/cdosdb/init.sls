mysql_setup:
  debconf.set:
    - name: mysql-server-5.6
    - data:
        'mysql-server/root_password': {'type': 'string', 'value': '{{ pillar.cdos.mysql.rootpass }}'}
        'mysql-server/root_password_again': {'type': 'string', 'value': '{{ pillar.cdos.mysql.rootpass }}'}

python-mysqldb:
  pkg.latest: []

mysql-server-5.6:
  pkg.installed:
  - require:
    - debconf: mysql_setup
    - pkg: python-mysqldb

configure_for_cdos:
  file.managed:
  - name: /etc/mysql/conf.d/mysqld_cdos.cnf
  - contents: |
      [mysqld]
      # make sure we listen on openstack network for connections from our portal
      bind-address            = {{ grains.ip4_interfaces.eth1[0] }}
  - mode: 0644
  - user: root
  - group: root
  - makedirs: True
  - require:
    - pkg: mysql-server-5.6

ensure_config_used:
  service.running:
  - name: mysql
  - watch:
    - file: configure_for_cdos

