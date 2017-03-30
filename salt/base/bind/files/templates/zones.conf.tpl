//
// BIND zone config file - include all files from conf directory
//
// {{ pillar.defaults.hint }}
//

{% set confpath = "/etc/bind/zones/conf" -%}
{% set files = salt.file.readdir(confpath) -%}
{% for file in files -%}
{% if file not in ['.', '..'] -%}
include "{{ "%s/%s"|format(confpath, file) }}";
{% endif -%}
{% endfor -%}
