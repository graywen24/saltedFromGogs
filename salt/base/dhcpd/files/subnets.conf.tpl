# dhcpd subnets include file
#
# {{ pillar.defaults.hint }}
#

{% set confpath = "/etc/dhcp/subnets" -%}
{% set files = salt.file.readdir(confpath) -%}
{% for file in files -%}
{% if file not in ['.', '..'] -%}
include "{{ "%s/%s"|format(confpath, file) }}";
{% endif -%}
{% endfor -%}
