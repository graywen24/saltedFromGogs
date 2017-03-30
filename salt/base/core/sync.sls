

sync_modules:
  module.run:
    - name: saltutil.sync_modules
    - refresh: True

sync_states:
  module.run:
    - name: saltutil.sync_states
    - refresh: True

sync_grains:
  module.run:
    - name: saltutil.sync_grains
    - refresh: True

refresh_pillar:
  module.run:
  - name: saltutil.refresh_pillar

update_mine:
  module.run:
  - name: mine.update
  - require:
    - module: refresh_pillar
    - module: sync_grains
