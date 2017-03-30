
provide_repository_server:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:repo'
  - tgt_type: compound
  - sls:
    - repo
