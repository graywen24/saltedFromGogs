eth2_bridgeport:
  network.managed:
    - name: eth2
    - enabled: True
    - type: eth
    - proto: manual

br-mgmt_bridge:
  network.managed:
    - name: br-mgmt
    - enabled: True
    - ipaddr: 172.21.48.10/24
    - type: bridge
    - proto: static
    - bridge: br-mgmt
    - delay: 0
    - ports: eth2
    - gateway: 172.21.48.1
