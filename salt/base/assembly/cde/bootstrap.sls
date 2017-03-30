
{% set target = pillar.get('target', 'ess-a1.cde.1nc') %}
{% set network_saltenv = pillar.get('scope', 'cde') %}

apply_roles_to_new_machine:
  salt.state:
  - sls: core.roles
  - tgt: '{{ target }}'

set_bootstrap_stint:
  salt.runner:
  - name: alchemy.stint_begin
  - saltenv: cde
  - stint_id: bootstrap
  - require:
    - salt: apply_roles_to_new_machine

refresh_pillar_for_new_machine:
  salt.function:
  - name: saltutil.refresh_pillar
  - tgt: '{{ target }}'
  - require:
    - salt: set_bootstrap_stint

apply_basic_states_to_new_machine:
  salt.state:
  - sls:
      - core.packages
      - core.timezone
      - core.sync
      - containerhost
      - core.grub
      - core.hosts
  - tgt: '{{ target }}'
  - require:
    - salt: refresh_pillar_for_new_machine

apply_network_configuration:
  salt.state:
  - sls: network.containerhost
  - tgt: '{{ target }}'
  - saltenv: {{ network_saltenv }}
  - require:
    - salt: apply_basic_states_to_new_machine

{% set containerlist = salt.container.masterlist('cde', role='seed') %}
{% for container, config in containerlist.iteritems() %}
{{ container }}_create_basic_containers:
  salt.state:
  - sls: container.deployed
  - tgt: {{ config.target }}
  - queue: True
  - pillar:
      container: {{ container }}
  - require:
    - salt: apply_network_configuration
  - require_in:
    - salt: wait_for_ready
{% endfor %}

wait_for_ready:
  salt.wait_for_event:
    - name: salt/minion/*/topic/ready/success
    - id_list:
      - repo-a1.cde.1nc
      - micros-a1.cde.1nc

set_small_stint:
  salt.runner:
  - name: alchemy.stint_begin
  - saltenv: cde
  - stint_id: small
  - require:
    - salt: wait_for_ready

refresh_pillar_for_all_machines:
  salt.function:
  - name: saltutil.refresh_pillar
  - tgt: '*.cde.1nc'
  - require:
    - salt: set_bootstrap_stint

rebuild_hosts:
  salt.state:
  - sls:
    - core.hosts
  - tgt: '*.cde.1nc'
  - require:
    - salt: refresh_pillar_for_all_machines

{% set containerlist = salt.container.masterlist('cde', role='maas') %}
{% for container, config in containerlist.iteritems() %}
{{ container }}_create_basic_containers:
  salt.state:
  - sls: container.deployed
  - tgt: {{ config.target }}
  - pillar:
      container: {{ container }}
  - require:
    - salt: rebuild_hosts
  - require_in:
    - salt: wait_for_maas_ready
{% endfor %}

wait_for_maas_ready:
  salt.wait_for_event:
    - name: salt/minion/*/topic/ready/success
    - id_list:
      - maas-a1.cde.1nc

enlist_commission_cde:
  salt.runner:
  - name: maas.enlist
  - environment: cde
  - require:
    - salt: wait_for_maas_ready
