include:
  - core.hosts
  - install.jdk

alchemy-cdos:
  pkg.installed:
  - require:
    - sls: install.jdk

profile_cdos:
  file.managed:
  - name: /etc/profile.d/cdos.sh
  - source: salt://cdos/files/cdos.profile
  - mode: 0775
  - user: root
  - group: root
  - template: jinja
  - require:
    - sls: install.jdk

{% for script in pillar.cdos.bin %}
{{ script }}_ensure_bash_is_set:
  file.replace:
  - name: /opt/cdos/bin/{{ script }}
  - pattern: "#!/bin/sh"
  - repl: "#!/bin/bash"
  - require:
    - pkg: alchemy-cdos
{% endfor %}

enable_1net_template:
  file.replace:
  - name: /opt/cdos/stratosphere/app-config.json
  - pattern: '"theme": "cdi"'
  - repl: '"theme": "1net"'
  - require:
    - pkg: alchemy-cdos

start_cdos:
  cmd.run:
  - name: . /etc/profile.d/java.sh; . /etc/profile.d/cdos.sh; service cdos start
