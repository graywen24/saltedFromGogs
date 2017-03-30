/**
 * The db_ido_mysql library implements IDO functionality
 * for MySQL.
 */

library "db_ido_mysql"

object IdoMysqlConnection "ido-mysql" {
  user = "{{ pillar.icinga.mysql.dbuser }}",
  password = "{{ pillar.icinga.mysql.dbpass }}",
  host = "{{ pillar.icinga.mysql.dbhost }}",
  database = "{{ pillar.icinga.mysql.dbname }}"

  instance_description = "AlchemyExclusiveCDO"
  cleanup = {
    downtimehistory_age = 48h
    logentries_age = 14d
  }

}
