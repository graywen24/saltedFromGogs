ldap-auth-config ldap-auth-config/bindpw password
ldap-auth-config ldap-auth-config/rootbindpw password
ldap-auth-config ldap-auth-config/move-to-debconf boolean true
ldap-auth-config ldap-auth-config/ldapns/base-dn string {{ pillar.ldap.suffix }}
ldap-auth-config ldap-auth-config/dbrootlogin boolean true
ldap-auth-config ldap-auth-config/ldapns/ldap_version select 3
ldap-auth-config ldap-auth-config/dblogin boolean false
ldap-auth-config ldap-auth-config/override boolean true
ldap-auth-config ldap-auth-config/pam_password select md5
ldap-auth-config ldap-auth-config/binddn string cn=admin,{{ pillar.ldap.suffix }}
ldap-auth-config ldap-auth-config/rootbinddn string cn=admin,{{ pillar.ldap.suffix }}
ldap-auth-config ldap-auth-config/ldapns/ldap-server string {{ pillar.ldap.servers }}
