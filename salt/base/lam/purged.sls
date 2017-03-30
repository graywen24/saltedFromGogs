lam_purged:
  pkg.purged:
  - pkgs:
    - alchemy-ldap-manager
    - apache2
    - php5*

data_removed:
  file.absent:
  - name: {{ pillar.lam.datadir }}
