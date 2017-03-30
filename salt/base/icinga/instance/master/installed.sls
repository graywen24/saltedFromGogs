
include:
  - icinga.instance.common.installed

icinga2_master_packages:
  pkg.latest:
  - pkgs:
    - icinga2-ido-mysql
{% if 'icinga_db_master' in grains.roles %}
    - mysql-client
    - python-mysqldb
{% endif %}

