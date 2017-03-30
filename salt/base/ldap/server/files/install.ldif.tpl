dn: {{ pillar.ldap.suffix }}
objectClass: top
objectClass: dcObject
objectClass: organization
o: 1-Net Singapore Pte Ltd
dc: cde
structuralObjectClass: organization

dn: cn=admin,{{ pillar.ldap.suffix }}
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword:: {{ pillar.ldap.adminpass }}
structuralObjectClass: organizationalRole

dn: ou=people,{{ pillar.ldap.suffix }}
objectClass: organizationalUnit
ou: people

dn: ou=groups,{{ pillar.ldap.suffix }}
objectClass: organizationalUnit
ou: groups

dn: ou=machines,{{ pillar.ldap.suffix }}
objectClass: organizationalUnit
ou: machines

dn: cn=cas,ou=groups,{{ pillar.ldap.suffix }}
objectClass: posixGroup
description: Cloud and Advanced Technologies
gidNumber: 500
cn: cas

dn: cn=ops,ou=groups,{{ pillar.ldap.suffix }}
objectClass: posixGroup
description: Operations
gidNumber: 501
cn: ops

dn: cn=csc,ou=groups,{{ pillar.ldap.suffix }}
objectClass: posixGroup
description: Customer Service
gidNumber: 502
cn: csc

dn: cn=logreader,ou=groups,{{ pillar.ldap.suffix }}
objectClass: posixGroup
description: Access to Kibana Dashboard (Logs)
gidNumber: 503
cn: logreader

dn: cn=auditreader,ou=groups,{{ pillar.ldap.suffix }}
objectClass: posixGroup
description: Access to Kibana Secure Dashboard (audit)
gidNumber: 504
cn: auditreader

dn: ou=policies,{{ pillar.ldap.suffix }}
objectClass: organizationalUnit
objectClass: top
ou: policies

dn: cn=default,ou=policies,{{ pillar.ldap.suffix }}
objectClass: pwdPolicy
objectClass: device
objectClass: top
pwdAttribute: userPassword
pwdMustChange: TRUE
pwdAllowUserChange: TRUE
pwdSafeModify: FALSE
pwdCheckQuality: 1
pwdLockout: TRUE
pwdMinAge: 0
pwdMaxAge: 7776000
pwdInHistory: 6
pwdGraceAuthNLimit: 0
pwdLockoutDuration: 0
pwdMaxFailure: 5
pwdFailureCountInterval: 3600
pwdExpireWarning: 1209600
pwdMinLength: 8
cn: default

dn: cn=replica,ou=policies,{{ pillar.ldap.suffix }}
objectClass: pwdPolicy
objectClass: device
objectClass: top
pwdAttribute: userPassword
cn: replica
pwdMinAge: 1
pwdMaxAge: 7776000
pwdInHistory: 6
pwdCheckQuality: 1
pwdGraceAuthNLimit: 0
pwdLockoutDuration: 0
pwdMaxFailure: 3
pwdFailureCountInterval: 3600
pwdMinLength: 15
pwdLockout: TRUE
pwdMustChange: FALSE
pwdAllowUserChange: TRUE
pwdSafeModify: FALSE
pwdExpireWarning: 1209600

dn: cn=syncuser,{{ pillar.ldap.suffix }}
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: syncuser
description: LDAP replica user
userPassword:: {{ pillar.ldap.syncpass.crypt }}
pwdPolicySubentry: cn=replica,ou=policies,{{ pillar.ldap.suffix }}
