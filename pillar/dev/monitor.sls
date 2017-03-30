monitor:
  moles:
    satellites:
      zone: dev-satellites
      endpoints:
        - dev-node-01.dev.1nc
#        - node01-02.dev.1nc
#        - node01-03.dev.1nc
      parent: masters
    hosts:
      parent: satellites
