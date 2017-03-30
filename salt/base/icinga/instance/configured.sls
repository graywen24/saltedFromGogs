
{% set mole = salt.icinga2.node_mole() %}
{% if mole == 'masters' %}
include:
  - .master.configured
{% elif mole == 'satellites' %}
include:
  - .satellite.configured
{% elif mole == 'hosts' %}
include:
  - .host.configured
{% endif %}
