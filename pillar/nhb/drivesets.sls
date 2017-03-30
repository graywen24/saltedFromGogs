drivesets:
  elastic:
    sdb:
      table: gpt
      partitions:
        1:
          start: 2048s
          end: 100%
          fs: ext4
          partlabel: elasticstore_01
    sdc:
      table: gpt
      partitions:
        1:
          start: 2048s
          end: 100%
          fs: ext4
          partlabel: elasticstore_02
