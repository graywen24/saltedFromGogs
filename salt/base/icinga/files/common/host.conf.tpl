/*
 * {{ pillar.defaults.hint }}
 */

{% set node = grains.nodename %}
{% set nodedata = salt.pillar.get('hosts:' + node, {}) %}
{% set nodedata = salt.pillar.get('containers:' + node, nodedata) %}

{% set hosttpl = nodedata.get('hosttpl', "generic-host") %}
{% set roles = salt.icinga2.pytoicingalist(grains.roles) %}

object Host NodeName {

  /* Set custom attributes */
  vars.os = "{{ salt.grains.get('os', 'Ubuntu')}}"
  vars.osname = vars.os
  vars.roles = {{ roles }}
  vars.rolenames = vars.roles
  vars.native = true

  /* Import the default host template defined in `templates.conf`. */
  import "{{ hosttpl }}"

  /* Specify the address attribute */
  address = NodeIP

}
