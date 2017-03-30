
put_debugcharm:
  file.recurse:
  - name: /home/ubuntu/trusty/debugcharm
  - source: salt://juju/files/debugcharm
  - user: ubuntu
  - group: ubuntu
  - makedirs: true
  - clean: true

set_exec_charm:
  file.managed:
  - name: /home/ubuntu/trusty/debugcharm/hooks/hooks.py
  - mode: 0775

do_links:
  cmd.run:
  - names:
    - ln -fs hooks.py install
    - ln -fs hooks.py upgrade-charm
    - ln -fs hooks.py config-changed
  - cwd: /home/ubuntu/trusty/debugcharm/hooks
  - user: ubuntu
  - group: ubuntu