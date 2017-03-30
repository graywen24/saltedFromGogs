elastic:
  node_heapsize: 8g
  home_dir: /usr/share/elasticsearch
  data_dir: /var/lib/elasticsearch
  log_dir: /var/log/elasticsearch
  clustername: elastic_bbox
  user: elasticsearch
  group: elasticsearch
  memory_lock: True
  max_locked_memory: unlimited
  max_map_count: 262144
  http_port: 9200
  masterlist: 10.2.48.133, 10.2.48.134, 10.2.48.135
  javaopts: ""
