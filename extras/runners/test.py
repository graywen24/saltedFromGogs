from __future__ import absolute_import
import salt.client
import salt.runner
import salt.config
import salt.utils
import logging
import cpillar, nodebase

log = logging.getLogger(__name__)


def look(environment, pillar=""):
  '''
  Lookup the pillar for a specific pillar environment

  CLI Example:

  .. code-block:: bash

      salt-run test.look dev defaults:network

  :param environment:
    The name of the pillar environment to get

  :param pillar:
    The pillar path to return in colon notation

  :return:
    The pillar dict found or none
  '''
  _pillar = cpillar.fake_pillar(None, environment, '1nc', __opts__)
  leaf = cpillar.dig(_pillar, pillar)

  res = leaf
  tree = pillar.split(':')

  for branch in tree:
    res = {branch: res}

  return res


def list_nodes(environment, groups="hosts", top="1nc"):
  '''
  Function that lists out all nodes in an environment - for manual configuration checks

  CLI Example:

  .. code-block:: bash

      salt-run test.list_nodes dev
      salt-run test.list_nodes dev containers

  :param environment:
    The saltenv you want the dns zone files be created for

  :param top:
    The top level domain if none is given in the pillar configuration for the environment/network

  :return:
    If just for test, returns the data created. If run, it returns the state results

  '''
  _pillar = cpillar.fake_pillar(None, environment, top, __opts__)
  _networks = cpillar.dig(_pillar, "defaults:network", {})
  _ignorelist = ['common', 'schema']

  _nodes = {}
  groups = groups.split(',')
  for group in groups:
    partial = cpillar.dig(_pillar, group, {})
    _nodes.update(partial)

  snodelist = sorted(_nodes.keys())

  headers = [
    'id',
    'nature',
    'ip',
    'target',
    'rackid'
  ]

  for network in _networks.keys():

    if network in _ignorelist:
      continue

    headers.append(network + ':fqdn')
    headers.append(network + ':ip4')
    headers.append(network + ':mac')

  _infonodes = []

  for id in snodelist:

    node = _nodes.get(id, {})
    if node.get('nature') == 'hosts':
      node['target'] = cpillar.dig(node, 'network:manage:fqdn', id)

    _nodenetworks = [id, node.get('nature', ''), node.get('ip4').__str__(), node.get('target', ''),
                     node.get('rackid', '')]
    for network in _networks.keys():

      if network in _ignorelist:
        continue

      _ndata = node.get('network', {}).get(network, {})

      _nodenetworks.append(_ndata.get('fqdn', ''))
      _nodenetworks.append(_ndata.get('ip4', ''))
      _nodenetworks.append(_ndata.get('mac', ''))

    _infonodes.append(','.join(_nodenetworks))

  _infonodes.insert(0, ','.join(headers))
  return '\n'.join(_infonodes)


def list_nodebase(groups='hosts', *args):
  '''
  Function that lists out all items in a list of files given on the command line

  CLI Example:

  .. code-block:: bash

      salt-run test.list_nodebase
      salt-run test.list_nodebase containers

  :return:
    If just for test, returns the data created. If run, it returns the state results

  '''

  nodebase_files = list(args)
  nodebase_data = nodebase.data(nodebase_files, __opts__['file_buffer_size'])

  headers = [
    'id',
    'nature',
    'ip',
    'networks',
    'roles'
  ]

  _infonodes = []
  groups = groups.split(',')

  for group in groups:

    _nodes = nodebase_data.get(group, {})
    snodelist = sorted(_nodes.keys())

    for id in snodelist:

      node = _nodes.get(id, {})
      info = []
      info.append(id)
      info.append(group)
      info.append(node.get('ip4').__str__())
      info.append('/'.join(node.get('network', {}).keys()))
      info.append('/'.join(node.get('roles', [])))

      _infonodes.append(','.join(info))

  _infonodes.insert(0, ','.join(headers))
  return '\n'.join(_infonodes)

def success():
  ret = {'data':{'retcode': 0 }, 'outputter': 'nested'}
  return ret

def fail():
  ret = {'data':{'retcode': 1 }, 'outputter': 'nested'}
  return ret
