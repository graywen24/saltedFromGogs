elastic:
  node_heapsize: 3g
  home_dir: /usr/share/elasticsearch
  data_dir: /var/lib/elasticsearch
  data_dirs:
    - sdb1
    - sdc1
    - sdd1
  log_dir: /var/log/elasticsearch
  clustername: elastic_dev
  user: elasticsearch
  group: elasticsearch
  memory_lock: True
  max_locked_memory: unlimited
  max_map_count: 262144
  http_port: 9200
  masterlist: 10.99.98.133, 10.99.98.134, 10.99.98.135
  javaopts: ""
