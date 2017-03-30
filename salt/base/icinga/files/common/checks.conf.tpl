/**
* Icinga 2 checks configuration file
*
* {{ pillar.defaults.hint }}
*/

{% set allchecks = salt.icinga2.node_checks() -%}

/*
{{ allchecks }}
*/

{% for singlecheck in allchecks.includes -%}
include "/etc/icinga2/checks.d/{{ singlecheck }}.conf"
{% endfor %}
