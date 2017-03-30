
remove_all_packages:
  pkg.purged:
  - pkgs:
    - libvirt-bin
    - qemu-kvm

autoremove_installed_packages:
  cmd.run:
  - name: apt-get -y autoremove --purge
