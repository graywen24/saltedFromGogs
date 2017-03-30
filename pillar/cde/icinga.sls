icinga:
  salt: 263f17e3975c0c69cdc09d5036b3925d
  apipwd: TestIt16
  mysql:
    dbaccesshost: icinga-%.cde.1nc
    dbhost: icingadb.cde.1nc
    dbname: icinga2
    dbuser: icinga
    dbpass: WooZoodaib2aeph
    grants: create, drop, alter, select, insert, update, delete, drop, create view, index, execute
    schema: /usr/share/icinga2-ido-mysql/schema/mysql.sql
    upgrades: /usr/share/icinga2-ido-mysql/schema/upgrade/{}.sql
    socket: /run/mysqld/mysqld.sock
    charset: utf8
  web:
    modules:
      iframe: False
      monitoring: True
      setup: False
      translation: False
  graphite:
    key: 0ekdjfaoeia-3jdeidid9e983
    dbname: graphite
    port: 8000
  upgrades:
    1.11.6: 2.1.0
    1.11.7: 2.2.0
    1.12.0: 2.3.0
    1.13.0: 2.4.0
    1.14.0: 2.5.0
