# {{ pillar.defaults.hint }}
# Contents taken from pillar {{ pillar_id }}

{% set contents = salt['pillar.get'](pillar_id, "# INFO: url not set or set to none.") -%}
{{ contents }}
