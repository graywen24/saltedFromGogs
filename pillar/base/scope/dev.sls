defaults:
  bashtimeout: 0
  hostsfile:
    ess-a1.cde.1nc ess-a1 salt.cde.1nc salt: 192.168.48.10
    repo-a1.cde.1nc repo.cde.1nc repo-a1 repo: 192.168.48.101
    micros-a1.cde.1nc micros-a1: 192.168.48.103
    ldap-a1.cde.1nc: 192.168.48.108
    ldap-a2.cde.1nc: 192.168.48.111
apt:
  sources:
    alchemy: None
#extras:
#  apt:
#    alchemy_dev: # will be deleted if exists
#    alchemy_test_co: deb http://repo.cde.1nc/testing/common trusty/
#    alchemy_test_ex: deb http://repo.cde.1nc/testing/exclusive trusty/
