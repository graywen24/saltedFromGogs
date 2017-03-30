
# ensure roles being set correctly
ensure_roles_set:
  salt.state:
  - tgt: '*.cde.1nc'
  - sls:
    - core.roles

# install icinga database
provide_icinga_database:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:icinga_idodb'
  - tgt_type: compound
  - sls:
    - icinga.database.installed
  - require:
    - salt: ensure_roles_set

configure_icinga_database:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:icinga_idodb'
  - tgt_type: compound
  - sls:
    - icinga.database.configured
  - require:
    - salt: provide_icinga_database

# install icinga master
provide_icinga_master:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:icinga_db_master'
  - tgt_type: compound
  - sls:
    - icinga.instance.installed
  - require:
    - salt: configure_icinga_database

configure_icinga_master:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:icinga_db_master'
  - tgt_type: compound
  - sls:
    - icinga.instance.configured
  - require:
    - salt: provide_icinga_master

# install icinga web
provide_icinga_web:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:icinga_web'
  - tgt_type: compound
  - sls:
    - icinga.web.installed

configure_icinga_web:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:icinga_web'
  - tgt_type: compound
  - sls:
    - icinga.web.configured
  - require:
    - salt: provide_icinga_web

# install graphite into icinga web
provide_graphite_icinga_web:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:icinga_web'
  - tgt_type: compound
  - sls:
    - icinga.graphite.installed
  - require:
    - salt: configure_icinga_web

configure_graphite_icinga_web:
  salt.state:
  - tgt: '*.cde.1nc and G@roles:icinga_web'
  - tgt_type: compound
  - sls:
    - icinga.graphite.configured
  - require:
    - salt: provide_graphite_icinga_web

