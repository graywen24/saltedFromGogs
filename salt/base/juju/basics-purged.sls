
purge_charms:
  file.absent:
  - name: /home/ubuntu/trusty

purge_meta:
  file.absent:
  - name: /home/ubuntu/metadata
