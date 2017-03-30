/**
 * {{ pillar.defaults.hint }}
 */

{%- set mole = salt.icinga2.node_mole() %}
object ApiListener "api" {
  cert_path = SysconfDir + "/icinga2/pki/" + NodeName + ".crt"
  key_path = SysconfDir + "/icinga2/pki/" + NodeName + ".key"
  ca_path = SysconfDir + "/icinga2/pki/ca.crt"
{% if 'icinga_db_master' in grains.roles %}
  ticket_salt = TicketSalt
  accept_config = false
  accept_commands = false
{%- elif mole == 'masters' %}
  accept_config = true
  accept_commands = true
{%- elif mole == 'satellites' %}
  accept_config = true
  accept_commands = true
{%- else %}
  accept_config = true
  accept_commands = true
{% endif %}
}
