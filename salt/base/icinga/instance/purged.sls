{% set mole = salt.icinga2.node_mole() %}
{% if mole == 'masters' %}
include:
  - .master.purged
{% elif mole == 'satellites' %}
include:
  - .satellite.purged
{% elif mole == 'hosts' %}
include:
  - .host.purged
{% endif %}