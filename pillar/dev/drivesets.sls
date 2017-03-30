drivesets:
  elastic:
    vdb:
      table: gpt
      partitions:
        1:
          start: 2048s
          end: 100%
          fs: ext4
          partlabel: elasticstore_01
    vdc:
      table: gpt
      partitions:
        1:
          start: 2048s
          end: 100%
          fs: ext4
          partlabel: elasticstore_02
    vdd:
      table: gpt
      partitions:
        1:
          start: 2048s
          end: 100%
          fs: ext4
          partlabel: elasticstore_03
