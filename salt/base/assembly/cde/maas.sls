
ensure_roles_set:
  salt.state:
  - tgt: '*.cde.1nc'
  - sls:
    - core.roles

provide_maas_server:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:maas'
  - tgt_type: compound
  - sls:
    - maas

