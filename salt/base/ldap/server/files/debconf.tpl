slapd slapd/internal/adminpw password {{ pillar.ldap.firstpass }}
slapd slapd/internal/generated_adminpw password {{ pillar.ldap.firstpass }}
slapd slapd/password1 password {{ pillar.ldap.firstpass }}
slapd slapd/password2 password {{ pillar.ldap.firstpass }}
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/dump_database select when needed
slapd slapd/domain string {{ pillar.ldap.domain }}
slapd slapd/purge_database boolean true
slapd shared/organization string {{ pillar.ldap.organisation }}
slapd slapd/move_old_database boolean true
slapd slapd/backend select HDB
slapd slapd/no_configuration boolean true
slapd slapd/dump_database_destdir string {{ pillar.ldap.backupdir }}
