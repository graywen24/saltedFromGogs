# Import python libs
from __future__ import absolute_import
import salt

# Set up logging
import logging

logger = logging.getLogger(__name__)


def __virtual__():
  if salt.utils.which('maas-region-admin'):
    return True
  return False


def cluster_created(name, domain, status=1, ip=None):
  '''
  This ensures that the given cluster exists on the MaaS server running on the target. If the cluster
  does not exist, it will be created. If it exists, name and settings will be applied.

  :param name:
    The desired name of the cluster.

  :param domain:
    The desired domain for the cluster

  :param status:
    The desired status for the cluster

  :param ip:
    The ip address, this cluster is bound to

  :return:
    A state result dict
  '''
  ret = {'changes': {},
         'comment': 'The cluster is in the correct state',
         'name': name,
         'result': True}

  # find the cluster by name first
  nguuid = __salt__['maas.nodegroup_by_name'](name)

  # cluster not found by name - try the ip given or derrived ..
  if nguuid is None:
    if ip is None:
      ip = __salt__['pillar.get']('local:network:manage:ip4')

    logger.debug("Not found by name - searching by IP {}".format(ip))
    nguuid = __salt__['maas.nodegroup_by_ip'](ip)

  logger.debug("UUID of the cluster {} is {}".format(name, nguuid))
  ngdata = __salt__['maas.nodegroup'](nguuid)

  # this nodegroup does not exist - create it
  if ngdata is None:
    # TODO: enable actual creation of the cluster
    # ngdata = {'cluster_name': name, 'name': domain, 'status': status}
    # ret['changes']['new'] = ngdata
    # ret['comment'] = "A new cluster definition has been created"
    ret['comment'] = 'The cluster {} does not exist!'.format(name)
    return ret

  collect_data = {}
  collect_changes = {}
  if ngdata.get('cluster_name') != name:
    collect_data['cluster_name'] = unicode(name)
    collect_changes['cluster_name'] = 'Changed to {}'.format(name)

  if ngdata.get('name') != domain:
    collect_data['name'] = unicode(domain)
    collect_changes['name'] = 'Changed to {}'.format(domain)

  if ngdata.get('status') != status:
    collect_data['status'] = status
    collect_changes['status'] = 'Changed to {}'.format(status)

  if len(collect_changes) > 0:
    ret['changes']['edited'] = collect_changes
    ret['comment'] = "Changes applied"
    call_result = __salt__['maas.nodegroup_save'](nguuid, **collect_data)
    logger.debug('Save request result: %s', call_result)

  return ret


def interface_created(name, cluster, ip=None):
  '''
  This state will ensure that the named interface exists and is assigned to the
  cluster given.
  :param name:
    Name of the interface to search for, i.e. eth0, eth1

  :param cluster:
    The name of the cluster this interface should be assigned to

  :param ip:
    Optionally the IP this interface should be configured with

  :return:
    A state result dict
  '''

  ret = {'changes': {},
         'comment': 'The interface is in the correct state',
         'name': name,
         'result': True}

  # find the cluster by name first
  nguuid = __salt__['maas.nodegroup_by_name'](cluster)
  ifdata = __salt__['maas.nodegroup_interface_by_name'](name, nguuid)

  # cluster not found by name - try the ip given or derrived ..
  if ifdata is None:
    if ip is None:
      ip = __salt__['pillar.get']('local:network:manage:ip4')

    logger.debug("Not found by name - searching by IP {}".format(ip))
    name = __salt__['maas.nodegroup_interface_by_ip'](ip, nguuid)
    ifdata = __salt__['maas.nodegroup_interface_by_name'](name, nguuid)

  logger.debug("Interface data: %s", ifdata)
  return ret


def configured(name, value):
  '''
  Ensures that a given configuration item is set to value.

  :param name:
    Configuration item to inspect

  :param value:
    Value this item should have

  :return:
    A state result dict
  '''

  ret = {'changes': {},
         'comment': 'The value is already set',
         'name': name,
         'result': True}

  current = __salt__['maas.config_get'](name)

  if current != value:
    op = __salt__['maas.config_set'](name, value)
    ret['comment'] = "Changes applied"
    ret['changes']['changed'] = {name: "Changed to {}: {}".format(value, op)}

  return ret


def bootsource(name, bid, url, keyring=None):
  '''
  Manages a bootsource for the targeted MaaS server

  :param name:
    The name of the target - bootsources have no name field, so this is just descriptive

  :param bid:
    The bootsource id. On a new installation this would be id 1

  :param url:
    The url the bootsource should point to

  :param keyring:
    The path and the filename for the keyring used by this bootsource

  :return:
    A state result dict
  '''
  # TODO: create bootsource if not exists

  ret = {'changes': {},
         'comment': 'The bootsource {} is already in the correct state'.format(bid),
         'name': name,
         'result': True}

  changes = {}
  current = __salt__['maas.boot_source'](bid)

  if current['url'] != url:
    current['url'] = url
    changes['url'] = url

  if keyring is not None and current['keyring_filename'] != keyring:
    current['keyring'] = keyring
    changes['keyring'] = keyring

  if len(changes) > 0:
    op = __salt__['maas.boot_source_save'](bid, **changes)
    logger.info('Update result: %s', op)
    ret['changes']['changed'] = changes
    ret['comment'] = "Changes applied"

  return ret

