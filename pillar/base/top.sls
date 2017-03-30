{% set scope = salt.config.get('scope', None) %}
base:
  'roles:host':
    - match: grain
    - grub
  'G@roles:icinga_db_master or G@roles:icinga_idodb':
    - match: compound
    - mysql
  '*':
    - lxc_config
    - defaults
    - ldap
    - system
    - apt
    - monitor
{% if scope %}
    - scope.{{ scope }}
{% endif %}
cde:
  '*.cde.1nc and G@roles:ldapmgr':
    - match: compound
    - lam
  '*.cde.1nc and G@roles:smsgw':
    - match: compound
    - desms
  '*.cde.1nc and G@roles:twofa':
    - match: compound
    - defa
  '*.cde.1nc and G@roles:smarthost':
    - match: compound
    - mail
  '*.cde.1nc and G@roles:icinga':
    - match: compound
    - icinga
  '*.cde.1nc*':
    - defaults
    - stints
    - hosts
    - containers
    - environments
    - monitor
    - maas
{% if scope %}
    - scope.{{ scope }}
{% endif %}
bbox:
  '*.bbox.1nc':
    - defaults
    - hosts
    - containers
  '*.bbox.1nc and G@roles:cdos':
    - match: compound
    - cdos
  '*.bbox.1nc and G@roles:cdostmp':
    - match: compound
    - cdos
dev:
  '*.dev.1nc':
    - defaults
    - hosts
    - containers
    - monitor
    - elastic
    - drivesets
nhb:
  '*.nhb.1nc':
    - defaults
    - hosts
    - containers
    - monitor    
#  '*.nhb.1nc and G@roles:cdos':
#    - match: compound
#    - cdos
#  '*.nhb.1nc and G@roles:cdostmp':
#    - match: compound
#    - cdos
#  'roles:elastic':
#    - match: grain
#    - elastic
vstage:
  '*.vstage.1nc':
    - defaults
    - hosts
    - containers
    - monitor
#  'roles:host':
#    - match: grain
#    - drivesets
#  'roles:cdos':
#    - match: grain
#    - cdos
#  'roles:cdostmp':
#    - match: grain
#    - cdos
#  'roles:elastic':
#    - match: grain
#    - elastic
wcc:
  '*.wcc.1nc':
    - defaults
    - hosts
    - containers
    - monitor
#  'roles:host':
#    - match: grain
#    - drivesets
#  'roles:cdos':
#    - match: grain
#    - cdos
#  'roles:cdostmp':
#    - match: grain
#    - cdos
#  'roles:elastic':
#    - match: grain
#    - elastic
