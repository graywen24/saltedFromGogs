
configure_instance:
  file.managed:
  - name: /etc/mysql/conf.d/icingadb.cnf
  - source: salt://icinga/database/files/icingadb.cnf
  - watch_in:
    - service: mysqlservice

has_icingadb_database:
  mysql_database.present:
  - name: {{ pillar.icinga.mysql.dbname }}
  - connection_unix_socket: {{ pillar.icinga.mysql.socket }}
  - connection_user: {{ pillar.mysql.adminuser }}
  - connection_pass: {{ pillar.mysql.adminpass }}
  - connection_charset: {{ pillar.icinga.mysql.charset }}
  - watch_in:
    - service: mysqlservice

has_graphite_database:
  mysql_database.present:
  - name: {{ pillar.icinga.graphite.dbname }}
  - connection_unix_socket: {{ pillar.icinga.mysql.socket }}
  - connection_user: {{ pillar.mysql.adminuser }}
  - connection_pass: {{ pillar.mysql.adminpass }}
  - connection_charset: {{ pillar.icinga.mysql.charset }}
  - watch_in:
    - service: mysqlservice

configure_admin_user:
  mysql_user.present:
  - name: {{ pillar.mysql.adminuser }}
  - host: {{ pillar.icinga.mysql.dbaccesshost }}
  - password: {{ pillar.mysql.adminpass }}
  - connection_unix_socket: {{ pillar.mysql.socket }}
  - connection_user: {{ pillar.mysql.adminuser }}
  - connection_pass: {{ pillar.mysql.adminpass }}
  - connection_charset: {{ pillar.icinga.mysql.charset }}
  - watch_in:
    - service: mysqlservice

grants_admin_user:
  mysql_grants.present:
  - grant: all privileges
  - database: {{ pillar.icinga.mysql.dbname }}.*
  - user: {{ pillar.mysql.adminuser }}
  - host: {{ pillar.icinga.mysql.dbaccesshost }}
  - connection_unix_socket: {{ pillar.icinga.mysql.socket }}
  - connection_user: {{ pillar.mysql.adminuser }}
  - connection_pass: {{ pillar.mysql.adminpass }}
  - connection_charset: {{ pillar.icinga.mysql.charset }}
  - watch_in:
    - service: mysqlservice

configure_icingadb_user:
  mysql_user.present:
  - name: {{ pillar.icinga.mysql.dbuser }}
  - host: {{ pillar.icinga.mysql.dbaccesshost }}
  - password: {{ pillar.icinga.mysql.dbpass }}
  - connection_unix_socket: {{ pillar.icinga.mysql.socket }}
  - connection_user: {{ pillar.mysql.adminuser }}
  - connection_pass: {{ pillar.mysql.adminpass }}
  - connection_charset: {{ pillar.icinga.mysql.charset }}
  - watch_in:
    - service: mysqlservice

grants_icingadb_user:
  mysql_grants.present:
  - grant: {{ pillar.icinga.mysql.grants }}
  - database: {{ pillar.icinga.mysql.dbname }}.*
  - user: {{ pillar.icinga.mysql.dbuser }}
  - host: {{ pillar.icinga.mysql.dbaccesshost }}
  - connection_unix_socket: {{ pillar.icinga.mysql.socket }}
  - connection_user: {{ pillar.mysql.adminuser }}
  - connection_pass: {{ pillar.mysql.adminpass }}
  - connection_charset: {{ pillar.icinga.mysql.charset }}
  - watch_in:
    - service: mysqlservice

grants_graphite_icinga_user:
  mysql_grants.present:
  - grant: {{ pillar.icinga.mysql.grants }}
  - database: {{ pillar.icinga.graphite.dbname }}.*
  - user: {{ pillar.icinga.mysql.dbuser }}
  - host: {{ pillar.icinga.mysql.dbaccesshost }}
  - connection_unix_socket: {{ pillar.icinga.mysql.socket }}
  - connection_user: {{ pillar.mysql.adminuser }}
  - connection_pass: {{ pillar.mysql.adminpass }}
  - connection_charset: {{ pillar.icinga.mysql.charset }}
  - watch_in:
    - service: mysqlservice


mysqlservice:
  service.running:
  - name: mysql
  - sig: mysqld

