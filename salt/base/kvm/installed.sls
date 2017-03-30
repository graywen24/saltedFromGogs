
qemu_libvirt_packages:
  pkg.installed:
  - install_recommends: True
  - pkgs:
    - libvirt-bin
    - qemu-kvm
    - qemu-utils

ensure_ubuntu_in_kvm:
  group.present:
  - name: kvm
  - addusers:
    - ubuntu
  - require:
    - pkg: qemu_libvirt_packages

kvm_correct_rights:
  file.managed:
  - name: /dev/kvm
  - mode: 0660
  - user: root
  - group: kvm
  - require:
    - pkg: qemu_libvirt_packages
