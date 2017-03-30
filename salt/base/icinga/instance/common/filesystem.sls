# ensure we have our local directory
icinga2_local_dir:
  file.directory:
  - name: /etc/icinga2/local.d
  - watch_in:
    - service: icinga_service

# dont have conf dir
icinga_no_confdir:
  file.absent:
  - name: /etc/icinga2/conf.d
  - watch_in:
    - service: icinga_service

# dont need orig files
icinga_no_orig:
  cmd.run:
  - name: rm -f /etc/icinga2/*.orig
  - onlyif: test -f /etc/icinga2/*.orig
  - watch_in:
    - service: icinga_service

# make sure we have the pki dir with correct owner/group
icinga_pki_exists:
  file.directory:
  - name: /etc/icinga2/pki
  - user: nagios
  - group: nagios
  - watch_in:
    - service: icinga_service

debug_log_reset:
  file.absent:
  - name: /var/log/icinga2/debug.log
  - watch_in:
    - service: icinga_service
  - onlyif: test -e /etc/icinga2/features-enabled/debuglog.conf && test -e /var/log/icinga2/debug.log
