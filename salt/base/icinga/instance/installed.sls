

{% set mole = salt.icinga2.node_mole() %}
{% if mole == 'masters' %}
include:
  - .master.installed
{% elif mole == 'satellites' %}
include:
  - .satellite.installed
{% elif mole == 'hosts' %}
include:
  - .host.installed
{% endif %}
