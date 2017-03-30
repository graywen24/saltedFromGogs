cluster_cde:
  maas.cluster_created:
  - name: CDE
  - domain: cde.1nc
  - ip: 192.168.48.100

cluster_interface:
  maas.interface_created:
  - name: eth0
  - cluster: CDE

cluster_archive:
  maas.configured:
  - name: main_archive
  - value: {{ pillar.maas.archive }}

cluster_boot_source:
  maas.bootsource:
  - id: 1
  - url: {{ pillar.maas.bootsource.url }}
  - keyring: {{ pillar.maas.bootsource.keyring }}

# TODO: add cluster ntp server
# TODO: add ssh keys for root user
