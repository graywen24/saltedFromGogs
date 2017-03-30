/**
 * {{ pillar.defaults.hint }}
 *
 * The GraphiteWriter type writes check result metrics and
 * performance data to a graphite tcp socket.
 */

library "perfdata"

object GraphiteWriter "graphite" {

  //host = "127.0.0.1"
  //port = 2003

  host_name_template = "icinga2.$host.name$.host.$host.check_command$"
  service_name_template = "icinga2.$host.name$.services.$service.name$.$service.name$"

}
