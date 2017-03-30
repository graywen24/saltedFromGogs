apt:
  sources:
    main: |
        deb http://repo.cde.1nc/cde/ubuntu trusty main restricted universe multiverse
        deb http://repo.cde.1nc/cde/ubuntu trusty-updates main restricted universe multiverse
        deb http://repo.cde.1nc/cde/ubuntu trusty-security main restricted universe multiverse
    alchemy: deb http://repo.cde.1nc/cde/alchemy trusty main extra
    salt: deb http://repo.cde.1nc/cde/salt trusty main
    icinga: deb http://repo.cde.1nc/cde/icinga trusty main
    elastic: deb http://repo.cde.1nc/cde/elastic trusty main
    maas: deb http://repo.cde.1nc/cde/maas trusty main
  deprecated:
    - saltstack.list
    - alchemy.sources.list
  configs:
    02recommends: APT::Install-Recommends "false";
  keys:
    default:
      249C4A666CBE5D2D: alchemy.key
      0E08A149DE57BFBE: salt.key
      C6E319C334410682: icinga.key
    deprecated: # make sure these old keys are removed
      E083A3782A194991: aptly
    repos:
      57A48F2F1793CB0C: aptly.key
    maas:
      5CFF1EA993EE8CC5: maas.key
    ubuntu:
      40976EAF437D05B5: ubuntu_legacy.key
      3B4FE6ACC0B21F32: ubuntu.key

