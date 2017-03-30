
# ensure every host here has the bbox pointer ...

workspace:
  grains.absent:
    - value: bbox
