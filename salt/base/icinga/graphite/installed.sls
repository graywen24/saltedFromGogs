

icinga2_graphite_packages:
  pkg.installed:
  - pkgs:
    - libapache2-mod-wsgi
    - graphite-web
    - graphite-carbon

icingaweb2_module:
  file.recurse:
  - name: /usr/share/icingaweb2/modules/graphite
  - source: salt://icinga/graphite/files/icingaweb2-module-graphite
  - makedirs: True

icingaweb2_templates:
  file.recurse:
  - name: /etc/icingaweb2/modules/graphite/templates
  - source: salt://icinga/graphite/files/config/templates
  - makedirs: True
