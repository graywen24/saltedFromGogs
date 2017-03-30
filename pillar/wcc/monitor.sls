monitor:
  moles:
    satellites:
      zone: wcc-satellites
      endpoints:
        - db-a1.wcc.1nc
        - db-a2.wcc.1nc
        - db-a3.wcc.1nc
      parent: masters
    hosts:
      parent: satellites
