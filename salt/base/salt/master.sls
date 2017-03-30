#TODO: Base path configuration paths on existing directories ...

salt-master-package:
  pkg.latest:
  - name: salt-master
  - version: {{ pillar.defaults.salt.version }}
  - kwargs:
      dist_upgrade: True

salt-master-config:
  file.recurse:
  - name: /etc/salt/master.d
  - source: salt://salt/files/master.d


{% if salt.file.file_exists('/etc/default/alchemy-scope') %}
salt_configure_scope:
  cmd.run:
  - name: 'source /etc/default/alchemy-scope; echo "scope: $SCOPE" > /etc/salt/master.d/scope.conf'
  - shell: /bin/bash
{% else %}
salt_configure_scope:
  file.absent:
  - name: /etc/salt/master.d/scope.conf
{% endif %}

{% for target, name in salt.pillar.get("system:plibs:master", {}).iteritems() %}
salt-master-libs-{{ name }}:
  file.symlink:
  - name: {{ name }}
  - target: {{ target }}
{% endfor %}

{% set pkgs = salt.pillar.get("system:packages:master", {}) %}
salt-master-pkgs:
  pkg.latest:
  - pkgs: {{ pkgs }}


# do not do this for now :)
#salt-service:
#  service.running:
#  - name: salt-master
#  - watch:
#    - file: salt-master-config