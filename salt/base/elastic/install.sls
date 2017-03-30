
alchemy-java:
  pkg.latest: []

alchemy-elasticsearch:
  pkg.latest: []

elastic_initd:
  cmd.run:
    - name: update-rc.d elasticsearch defaults 95 10
