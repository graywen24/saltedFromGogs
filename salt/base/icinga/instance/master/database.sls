
# TODO: do all this properly with execution modules and states
{% if 'icinga_db_master' in grains.roles %}
# Install and manage the database schema. Needs to be done
# from here as the schema files are only available with the
# idosql package.

#count_tables:
#  mysql_query.run:
#    - database: information_schema
#    - query: "SELECT count(*) as cnt FROM tables WHERE table_schema = '{{ pillar.icinga.mysql.dbname }}';"
#    - connection_host: {{ pillar.icinga.mysql.dbhost }}
#    - connection_user: {{ pillar.mysql.adminuser }}
#    - connection_pass: {{ pillar.mysql.adminpass }}
#    - connection_db: information_schema
#    - connection_charset: {{ pillar.icinga.mysql.charset }}
#    - output: grain
#    - grain: dbase


has_icingadb_tables:
  cmd.run:
    - name: mysql {{ pillar.icinga.mysql.dbname }} < {{ pillar.icinga.mysql.schema }}
    - env:
      - USER: '{{ pillar.mysql.adminuser }}'
      - MYSQL_PWD: '{{ pillar.mysql.adminpass }}'
      - MYSQL_HOST: '{{ pillar.icinga.mysql.dbhost }}'
    - unless:
      - mysql -u root -pEM3eeGee -h icingadb.cde.1nc icinga2 -e "select version from icinga_dbversion;"

{% set current_version = salt.icinga2.icingadb_info().get('version', '0.0.0') %}
{% set current_fileversion = salt.pillar.get('icinga:upgrades:' + current_version, '') %}
{% set current_file = salt.pillar.get('icinga:mysql:upgrades', '{}').format(current_fileversion) %}

{% if salt.file.file_exists(current_file) %}
has_icingadb_upgrades:
  cmd.run:
    - name: mysql {{ pillar.icinga.mysql.dbname }} < {{ current_file }}
    - env:
      - USER: '{{ pillar.mysql.adminuser }}'
      - MYSQL_PWD: '{{ pillar.mysql.adminpass }}'
      - MYSQL_HOST: '{{ pillar.icinga.mysql.dbhost }}'

{% endif %}
{% endif %}