
# Install net default before actual lxc package to prevent the lxcbr0 to
# be configured at the first place
lxc-net-default:
  file.managed:
    - name: /etc/default/lxc-net
    - contents: |
        # {{ pillar.defaults.hint }}
        #
        # Make sure lxcbr0 is prevented on this containerhost
        USE_LXC_BRIDGE="false"
    - mode: 0644

# Allow routing/ip forwarding on this host
conf_sysctl:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1

# install packages for containermanagement
lxc_pkgs:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - iptables
      - debootstrap
      - lxc
      - lxc-templates
    - install_recommends: False
    - reload_modules: True
    - require:
      - file: lxc-net-default

# we dont want to use dnsmasq on this machine
disable_dnsmasq:
  service.dead:
    - name: dnsmasq
    - enable: False
    - require:
      - pkg: lxc_pkgs

# TODO: import alchemy key into debian default keyring at /usr/share/keyrings/ubuntu-archive-keyring.gpg
# debootstrap is used by lxc-create but with the default keyring - we point it to the apt keyring
redirect_keyring:
  file.replace:
  - name: /usr/share/debootstrap/scripts/trusty
  - pattern: "^keyring .*"
  - repl: keyring /etc/apt/trusted.gpg

# default configuration file appended to container config when creating
install_default_container_config:
  file.managed:
    - name: /etc/lxc/dummy.conf
    - contents:
    - mode: 0644

# install configuration template for low sec containers
has_lxc_alchemy_configs:
  file.managed:
    - name: /usr/share/lxc/config/ubuntu.lowsec.conf
    - source: salt://containerhost/files/ubuntu.lowsec.conf
    - user: root
    - mode: 644
