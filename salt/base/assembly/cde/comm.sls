
ensure_roles_set:
  salt.state:
  - tgt: '*.cde.1nc'
  - sls:
    - core.roles

# orchestration states for sms service
provide_smsservice:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:smsgw'
  - tgt_type: compound
  - sls:
    - desms

# orchestration states for 2fa service
provide_2faservice:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:twofa'
  - tgt_type: compound
  - sls:
    - defa
  - require:
    - salt: provide_smsservice

# orchestration states for smarthost
provide_smarthost:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:smarthost'
  - tgt_type: compound
  - sls:
    - smarthost.installed

