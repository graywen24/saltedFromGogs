
distupgrade_system_manually:
  cmd.run:
  - name: apt-get clean; apt-get update; apt-get -q -y -o DPkg::Options::=--force-confold -o DPkg::Options::=--force-confdef dist-upgrade
