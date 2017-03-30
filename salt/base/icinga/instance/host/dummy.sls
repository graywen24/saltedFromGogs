
# if the action is deconfigure, remove the configuration files
# for the calling node
{% if pillar.action == 'deconfigure' %}

# TODO: need to remove single endpoints from zone until empty
delete_dummy_zone:
  file.absent:
  - name: /etc/icinga2/hosts.d/{{ pillar.zone }}.zone.conf
  - watch_in:
    - file: create_reload_semaphore

delete_dummy_config:
  file.absent:
  - name: /etc/icinga2/hosts.d/{{ pillar.endpoint }}.conf
  - watch_in:
    - file: create_reload_semaphore

{% else %}
{% if pillar.zone != salt.icinga2.node_zone() %}

create_dummy_zone:
  file.managed:
  - source: salt://icinga/files/host/dummy.zone.conf.tpl
  - name: /etc/icinga2/hosts.d/{{ pillar.zone }}.zone.conf
  - makedirs: True
  - template: jinja
  - watch_in:
    - file: create_reload_semaphore

{% endif %}

create_dummy_config:
  file.managed:
  - source: salt://icinga/files/host/dummy.conf.tpl
  - name: /etc/icinga2/hosts.d/{{ pillar.endpoint }}.conf
  - makedirs: True
  - template: jinja
  - watch_in:
    - file: create_reload_semaphore


{% endif %}

# If we changed anything, create a semaphore file that indicates
# the need to reload the icinga service
create_reload_semaphore:
  file.managed:
  - name: /tmp/icinga2.reload.semaphore
