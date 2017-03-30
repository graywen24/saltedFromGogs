alchemy-sms-gateway:
  pkg.latest: []
  
desms-config:
  file.managed:
  - name: /etc/desms.conf
  - source: salt://desms/files/desms.conf
  - template: jinja
  - makedirs: True
  
desms-service:
  service.running:
  - name: desms
  - watch:
    - file: desms-config

