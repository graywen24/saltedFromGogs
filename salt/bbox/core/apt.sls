
alchemy_repo:
  file.managed:
    - name: /etc/apt/sources.list.d/alchemy.list
    - source: salt://core/files/apt/alchemy.list

apt_update:
  cmd.run:
    - name: apt-get -qq update
    - watch:
      - file: alchemy_repo

