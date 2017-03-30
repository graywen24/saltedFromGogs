# {{ pillar.defaults.hint }}
#
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

BASE	{{ pillar.ldap.suffix}}
URI {{ pillar.ldap.servers }}

#SIZELIMIT	12
#TIMELIMIT	15
#DEREF		never

# TLS certificates (needed for GnuTLS)
TLS_CACERT	{{ pillar.defaults.ssl.basedir }}/chains/{{ pillar.ldap.cafile }}

