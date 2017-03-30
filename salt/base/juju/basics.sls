
juju-installed:
  pkg.installed:
  - pkgs:
    - juju-deployer
    - juju-core

extract_charms:
  archive.extracted:
  - name: /home/ubuntu/
  - source: http://repo.cde.1nc/files/charm_2015-09-16.tar.gz
  - source_hash: md5=174ea825c0964bb08ca4d572b176de39
  - archive_format: tar
  - if_missing: /home/ubuntu/trusty

extract_meta:
  archive.extracted:
  - name: /home/ubuntu/
  - source: http://repo.cde.1nc/files/metadata.tar.gz
  - source_hash: md5=3448c579ee7487efe6231c97a8b7ef59
  - archive_format: tar
  - if_missing: /home/ubuntu/metadata

permissons:
  file.directory:
  - names:
    - /home/ubuntu/trusty
    - /home/ubuntu/metadata
  - user: ubuntu
  - group: ubuntu
  - recurse:
    - user
    - group

put_keys:
  file.recurse:
  - name: /home/ubuntu/ssh
  - source: salt://juju/files/ssh
  - user: ubuntu
  - group: ubuntu
  - makedirs: true
  - clean: true

permissons_keys:
  file.directory:
  - name: /home/ubuntu/ssh
  - user: ubuntu
  - group: ubuntu
  - file_mode: 0600
  - recurse:
    - user
    - group
    - mode

