
test_blender:
  salt.state:
  - tgt: ess-a1.cde.1nc
  - saltenv: dev
  - sls:
    - blend_in
