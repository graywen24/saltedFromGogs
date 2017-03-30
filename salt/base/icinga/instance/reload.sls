
# reload the icinga service if semaphore file exists

icinga_semaphore_check:
  file.absent:
  - name: /tmp/icinga2.reload.semaphore

icinga_service_check:
  service.running:
  - name: icinga2
  - onlyif:
    - stat -t /usr/sbin/icinga2
  - watch:
    - file: icinga_semaphore_check

