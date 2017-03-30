# {{ pillar.defaults.hint }}
#
# defines specific access to some programs the user nagios needs
# to run with elevated rights

# on containerhosts, we need to have access to the namespaces
# so we can read the process status isolated
# (ps on a containerhost shows also all container processes)
nagios {{ grains.nodename }} = (root) NOPASSWD: /usr/sbin/service, /bin/true, /usr/bin/pgrep
