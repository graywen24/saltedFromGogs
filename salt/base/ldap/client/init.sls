
include:
  - ldap.common

ldap_client_preseed:
  debconf.set_file:
  - source: salt://ldap/client/files/debconf.tpl
  - template: jinja
  - require:
    - sls: ldap.common

client_pkgs:
  pkg.installed:
  - pkgs:
    - ldap-auth-client
    - libpam-script
    - nscd
    - auth-client-config
  - require:
    - debconf: ldap_client_preseed

pam_configs:
  file.recurse:
  - name: /usr/share/pam-configs
  - source: salt://ldap/client/files/pam-configs
  - makedirs: true
  - file_mode: 0664
  - require:
    - pkg: client_pkgs
  - onchanges_in:
    - cmd: run_pam_auth_update

pam_scripts:
  file.recurse:
  - name: /usr/share/libpam-script
  - source: salt://ldap/client/files/libpam-script
  - makedirs: true
  - file_mode: 0775
  - require:
    - pkg: client_pkgs

ldap_conf_sys:
  file.managed:
  - name: /etc/ldap.conf
  - source: salt://ldap/client/files/ldap.pam.conf.tpl
  - mode: 0664
  - template: jinja
  - require:
    - pkg: client_pkgs
  - onchanges_in:
    - cmd: make_nss_aware

conf_for_pam_script:
  file.managed:
  - name: /usr/share/pam-configs/pam_script
  - source: salt://ldap/client/files/pam_script.pam-configs.tpl
  - mode: 0664
  - require:
    - pkg: client_pkgs

conf_for_pam_ldap:
  file.managed:
  - name: /usr/share/pam-configs/ldap
  - source: salt://ldap/client/files/ldap.pam-configs.tpl
  - mode: 0664
  - template: jinja
  - require:
    - pkg: client_pkgs
  - onchanges_in:
    - cmd: make_nss_aware
    - cmd: run_pam_auth_update

create_common_auth_for_sshd:
  cmd.run:
  - name: cat /etc/pam.d/common-auth | grep -v pam_unix.so > /etc/pam.d/common-auth-sshd
  - require:
    - pkg: client_pkgs

create_pam_auth_for_sshd:
  file.managed:
  - name: /etc/pam.d/sshd
  - source: salt://ldap/client/files/sshd.pam.config
  - mode: 0664
  - require:
    - cmd: create_common_auth_for_sshd

make_nss_aware:
  cmd.run:
  - name: auth-client-config -t nss -p lac_ldap
  - require:
    - pkg: client_pkgs

run_pam_auth_update:
  cmd.run:
  - name: pam-auth-update --package --force
  - require:
    - pkg: client_pkgs

ensure_nscd:
  service.running:
  - name: nscd
  - watch:
    - file: ldap_conf_sys
