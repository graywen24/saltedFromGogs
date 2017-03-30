/*
* {{ pillar.defaults.hint }}
*/

object Host "{{ pillar.endpoint }}" {
  import "satellite-host"
  address = "{{ pillar.ip4 }}"
  zone = "{{ pillar.zone }}"
  vars.rolenames = {{ pillar.roles }}
  vars.osname = "{{ pillar.os }}"
  vars.molename = "{{ pillar.mole }}"
}

{% for service, config in pillar.services.iteritems() -%}
object Service "{{ service }}" {
  import "satellite-service"
  display_name = "{{ config.display_name }}"
  host_name = "{{ pillar.endpoint }}"
  zone = "{{ pillar.zone }}"
}

{% endfor %}


