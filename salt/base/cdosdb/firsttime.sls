
create_config:
  file.recurse:
  - name: /root/sphereds
  - source: salt://cdosdb/files/sphereds
  - clean: true
  - makedirs: true
  - template: jinja

init_executable:
  file.managed:
  - name: /root/sphereds/sphereds.init.sh
  - mode: 0755
  - require:
    - file: create_config

sites_executable:
  file.managed:
  - name: /root/sphereds/insert.org.sites.sh
  - mode: 0755
  - require:
    - file: create_config

run_db_script:
  cmd.run:
  - name: ./sphereds.init.sh
  - cwd: /root/sphereds
  - require:
    - file: init_executable
