
aptly:
  defaults:
    archs:
      - amd64
      - i386
    dists:
      - trusty
  publish:
    cde:
      alchemy:
        trusty:
          snapshots:
            main: rtalmup_20150819
            extra: rtextrap_20150819
      alchemy-testing:
        trusty:
          snapshots:
            main: rtalmut_current
            extra: rtextrat_current
      aptly:
        trusty:
          snapshots:
            main: aptly_20150819
      icinga:
        trusty:
          snapshots:
            main: icinga_20160524
      maas:
        trusty:
          snapshots:
            main: maas_20150819
      salt:
        trusty:
          snapshots:
            main: salt_2015.5_20160517
      ubuntu:
        trusty:
          snapshots:
            main: tma_20150819
            multiverse: tmu_20150819
            restricted: tre_20150819
            universe: tun_20150819
        trusty-backports:
          snapshots:
            main: tbma_20150819
            multiverse: tbmu_20150819
            restricted: tbre_20150819
            universe: tbun_20150819
        trusty-security:
          snapshots:
            main: tsma_20150819
            multiverse: tsmu_20150819
            restricted: tsre_20150819
            universe: tsun_20150819
        trusty-updates:
          snapshots:
            main: tuma_20150819
            multiverse: tumu_20150819
            restricted: ture_20150819
            universe: tuun_20150819
  mirrors:
    aptly:
      url: http://repo.aptly.info/
      components:
        - main
      distributions:
        - squeeze
    icinga:
      url: http://packages.icinga.org/ubuntu/
      components:
        - main
      distributions:
        - icinga-trusty
    lxc:
      url: http://ppa.launchpad.net/ubuntu-lxc/stable/ubuntu/
      components:
        - main
      distributions:
        - trusty
      options:
        - udeb
    maas:
      url: http://ppa.launchpad.net/maas-maintainers/stable/ubuntu/
      components:
        - main
      distributions:
        - trusty
      options:
        - udeb
    salt:
      url: http://ppa.launchpad.net/saltstack/salt/ubuntu/
      components:
        - main
      distributions:
        - trusty
      options:
        - udeb
    salt_2015.5:
      url: http://repo.saltstack.com/apt/ubuntu/14.04/amd64/2015.5/
      components:
        - main
      distributions:
        - trusty
    salt_official:
      url: http://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest/
      components:
        - main
      distributions:
        - trusty
    tbma:
      groups:
        - ubuntu-all
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - main
      distributions:
        - trusty-backports
      options:
        - udeb
    tbmu:
      groups:
        - ubuntu-all
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - multiverse
      distributions:
        - trusty-backports
      options:
        - udeb
    tbre:
      groups:
        - ubuntu-all
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - restricted
      distributions:
        - trusty-backports
      options:
        - udeb
    tbun:
      groups:
        - ubuntu-all
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - universe
      distributions:
        - trusty-backports
      options:
        - udeb
    tma:
      groups:
        - ubuntu-all
        - ubuntu-core
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - main
      distributions:
        - trusty
      options:
        - udeb
    tmu:
      groups:
        - ubuntu-all
        - ubuntu-core
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - multiverse
      distributions:
        - trusty
      options:
        - udeb
    tre:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - restricted
      distributions:
        - trusty
      options:
        - udeb
    tsma:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - main
      distributions:
        - trusty-security
      options:
        - udeb
    tsmu:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - multiverse
      distributions:
        - trusty-security
      options:
        - udeb
    tsre:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - restricted
      distributions:
        - trusty-security
      options:
        - udeb
    tsun:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - universe
      distributions:
        - trusty-security
      options:
        - udeb
    tuma:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - main
      distributions:
        - trusty-updates
      options:
        - udeb
    tumu:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - multiverse
      distributions:
        - trusty-updates
      options:
        - udeb
    tun:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - universe
      distributions:
        - trusty
      options:
        - udeb
    ture:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - restricted
      distributions:
        - trusty-updates
      options:
        - udeb
    tuun:
      url: http://sg.archive.ubuntu.com/ubuntu/
      components:
        - universe
      distributions:
        - trusty-updates
      options:
        - udeb
