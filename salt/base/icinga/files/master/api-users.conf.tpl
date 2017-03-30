/**
 * {{ pillar.defaults.hint }}
 *
 * The APIUser objects are used for authentication against the API.
 */

object ApiUser "root" {

  password = "{{ pillar.icinga.apipwd }}"
  // client_cn = ""

  permissions = [ "*" ]
}
