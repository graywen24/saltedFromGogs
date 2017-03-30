
trigger_minion_assembly:
  runner.alchemy.minion_assemble:
  - target: {{ data['id'] }}
  - caller: reactor

