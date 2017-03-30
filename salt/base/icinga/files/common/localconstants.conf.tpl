/*
 * {{ pillar.defaults.hint }}
 *
 * Shall contain local constants created for this host only
 */

NodeMole = "{{ salt.icinga2.node_mole() }}"

MysqlDisplayName = "MySQL Database"
MysqlHost = "localhost"

PgDisplayName = "PostgreSQL Database"
PgsqlHost = "localhost"

HttpPort = 80
HttpSsl = false
HttpForceTls = false

{% set node_roles = grains.roles -%}
{% set node_checks = salt.icinga2.node_checks()["includes"] -%}
{% set configurations = salt.icinga2.node_checks()["config"] -%}

{% for name, config in configurations.iteritems() -%}
{{ name.split('.')[0] }}["{{ name }}"] = {{ salt.icinga2.pytoicingadict(config) }}
{% endfor %}

{% if 'icinga_idodb' in node_roles -%}
MysqlDisplayName = "IDO Database"
MysqlUser = "{{ pillar.mysql.adminuser }}"
MysqlPW = "{{ pillar.mysql.adminpass }}"
{%- endif %}

{% if 'icinga_ha_master' in node_roles -%}
IdoType = "IdoMysqlConnection"
IdoName = "ido-mysql"
outdated = {
  "dbhost" = "{{ pillar.icinga.mysql.dbhost }}"
  "dbname" = "{{ pillar.icinga.mysql.dbname }}"
  "dbuser" = "{{ pillar.icinga.mysql.dbuser }}"
  "dbpass" = "{{ pillar.icinga.mysql.dbpass }}"
}

{%- endif %}

{% if 'maas' in node_roles -%}
{% set dbinfo = salt.icinga2.maasdb_info() -%}
PgDisplayName = "maas-db"
PgsqlHost = "{{ dbinfo.hostname }}"
PgsqlDb = "{{ dbinfo.database }}"
PgsqlUser = "{{ dbinfo.username }}"
PgsqlPW = "{{ dbinfo.password }}"
HttpDisplayName = "maas-web"
{%- endif %}

{% if 'ldap' in node_checks -%}
LdapBase = "{{ pillar.ldap.suffix }}"
LdapHost = "{{ grains.id }}"
{%- endif %}

{% if 'http' in node_checks and 'ldapmgr' in node_roles -%}
HttpDisplayName = "ldap-account-manager"
{%- endif %}

{% if 'http' in node_checks and 'repo' in node_roles -%}
HttpDisplayName = "apt repository service"
{%- endif %}

{% if 'http' in node_checks and 'icinga_web' in node_roles -%}
HttpDisplayName = "icinga-web"
{%- endif %}
