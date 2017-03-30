
icinga_service:
  service.running:
  - name: icinga2

icinga_cluster_update:
  module.run:
  - name: icinga2.cluster_update_request
  - source: {{ grains.id }}
  - onchanges:
    - service: icinga_service

