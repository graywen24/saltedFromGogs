# {{ pillar.defaults.hint }}
#
# This is the main slapd configuration file. See slapd.conf(5) for more
# info on the configuration options.

#######################################################################
# Global Directives:

# Features to permit
#allow bind_v2

# Schema and objectClass definitions
include         /etc/ldap/schema/core.schema
include         /etc/ldap/schema/cosine.schema
include         /etc/ldap/schema/nis.schema
include         /etc/ldap/schema/inetorgperson.schema
include         /etc/ldap/schema/ppolicy.schema

# Where the pid file is put. The init.d script
# will not stop the server if you change this.
pidfile         /var/run/slapd/slapd.pid

# List of arguments that were passed to the server
argsfile        /var/run/slapd/slapd.args

# Read slapd.conf(5) for possible values
loglevel        none
#config stats

# TLS setup
# security ssf=128
TLSCACertificateFile {{ pillar.defaults.ssl.basedir }}/chains/{{ pillar.ldap.cafile }}
TLSCertificateFile {{ pillar.defaults.ssl.basedir }}/ldap/{{ salt.pillar.get('local:ssl:ldap:cert', 'MISSING') }}
TLSCertificateKeyFile {{ pillar.defaults.ssl.basedir }}/ldap/{{ salt.pillar.get('local:ssl:ldap:key', 'MISSING') }}
TLSCiphersuite NORMAL

# The maximum number of entries that is returned for a search operation
sizelimit 500

# The tool-threads parameter sets the actual amount of cpu's that is used
# for indexing.
tool-threads 1

# Where the dynamically loaded modules are stored
modulepath	/usr/lib/ldap
moduleload	back_hdb

# required if the overlay is built dynamically
moduleload ppolicy
{%- if 'ldapmaster' in grains.roles %}
moduleload syncprov
{% endif %}

#######################################################################
# Backend config

backend		hdb
database        hdb
directory       "{{ pillar.ldap.datadir }}"

# The base of your directory in database #1
suffix          "{{ pillar.ldap.suffix }}"

overlay ppolicy
ppolicy_default cn=default,ou=policies,{{ pillar.ldap.suffix }}
ppolicy_forward_updates
# ppolicy_use_lockout
ppolicy_hash_cleartext
{%- if 'ldapmaster' in grains.roles %}
ppolicy_hash_cleartext

overlay syncprov
syncprov-checkpoint 100 10

{%- else %}
# rootdn directive for specifying a superuser on the database. This is needed
# for syncrepl.
rootdn          "cn=syncuser,{{ pillar.ldap.suffix }}"

syncrepl rid=1
         provider={{ pillar.ldap.servers.split(' ')[0] }}
         type=refreshOnly
         interval=00:15:00:00
         searchbase="{{ pillar.ldap.suffix }}"
         bindmethod=simple
         binddn="cn=syncuser,{{ pillar.ldap.suffix }}"
         credentials="{{ pillar.ldap.syncpass.real }}"
         retry="60 10 600 6 3600 10"

readonly on

{%- endif %}

dbconfig set_cachesize 0 2097152 0

# Number of objects that can be locked at the same time.
dbconfig set_lk_max_objects 1500
# Number of locks (both requested and granted)
dbconfig set_lk_max_locks 1500
# Number of lockers
dbconfig set_lk_max_lockers 1500

# Indexing options for database #1
index           objectClass,entryCSN,entryUUID eq

# Save the time that the entry gets modified, for database #1
lastmod         on

# Checkpoint the BerkeleyDB database periodically in case of system
# failure and to speed slapd shutdown.
checkpoint      512 30

# The userPassword by default can be changed
# by the entry owning it if they are authenticated.
# Others should not be able to see it, except the
# admin entry below
# These access lines apply to database #1 only
access to attrs=userPassword,shadowLastChange
        by dn="cn=admin,{{ pillar.ldap.suffix }}" write
{%- if 'ldapmaster' in grains.roles %}
        by dn="cn=syncuser,{{ pillar.ldap.suffix }}" read
{%- endif %}
        by anonymous auth
        by self write
        by * none

access to dn.base="" by * read

# The admin dn has full write access, everyone else
# can read everything.
access to *
        by dn="cn=admin,{{ pillar.ldap.suffix }}" write
        by * read

