create_admin:
  cmd.script:
    - source: salt://maas/files/createadmin.sh
    - env:
      - MAASADMIN: {{ pillar.maas.user }}
      - MAASPASS: {{ pillar.maas.pass }}
      - MAASEMAIL: {{ pillar.maas.email }}
