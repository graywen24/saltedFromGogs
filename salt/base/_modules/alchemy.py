'''
Expose alchemy helper functions

'''

# Import python libs
from __future__ import absolute_import
import logging

# Set up logging
log = logging.getLogger(__name__)

def test_data():
  '''
  Returns a data structure for testing purposes

  :return:
    Dict
  '''

  return {'levelone': {'leveltwo': {'string': 'Haha!', 'numeric': 666, 'list': ['one', 'two', 'three']}}}


def hint_drop(hint):
  '''
  Remove item from the hint structure

  :param hint:
    Colon delimited path to the hint one wants to delete

  :return:
    The updated hints data structure
  '''

  hints = __salt__['grains.get']('hints', {})

  subhint = hints
  subkeys = hint.split(':')
  for key in subkeys[:-1]:
    if key in subhint:
      subhint = subhint[key]

  delkey = subkeys[-1]
  if delkey in subhint:
    del subhint[delkey]

  return __salt__['grains.setval']('hints', hints)


def hint_add(hint, value):
  '''
  Add an item to the hint structure

  :param hint:
    Colon delimited path to the hint one wants to add

  :param value:
    The value for the hint to be added

  :return:
    The updated hints data structure
  '''

  hints = __salt__['grains.get']('hints', {})

  subhint = hints
  subkeys = hint.split(':')
  for key in subkeys[:-1]:
    if key not in subhint:
      subhint[key] = {}
      subhint = subhint[key]
    else:
      subhint = subhint[key]

  newkey = subkeys[-1]
  subhint[newkey] = value

  return __salt__['grains.setval']('hints', hints)


def apt_key_list():
  '''
  Return a list with applicable apt repo keys configured in apt pillar

  :return:
    A dict with two dicts, called installed and removed.
  '''

  keyblocks = __salt__['pillar.get']('apt:keys', {})
  installed = {}
  deprecated = keyblocks.get('deprecated', {})
  for role, data in keyblocks.iteritems():
    if role == 'deprecated':
      continue

    installed.update(data)

  return {'installed': installed, 'deprecated': deprecated}


def node_roles():
  '''
  Return a list of roles that apply to the current minion

  :return:
    A list of strings

  '''

  id = __salt__['grains.get']('nodename')
  for group in ['hosts', 'containers']:
    pillar_path = '{0}:{1}:roles'.format(group, id)
    log.warning(pillar_path)
    roles = __salt__['pillar.get'](pillar_path, None)
    if roles is not None:
      return roles

  return []


def host(name):
  '''
  Return the configuration for a specific host

  :param name:
    The canonical id of the host in question

  :return:
    Full configuration data structure

  '''

  config_path = 'hosts:' + name
  config = __salt__['pillar.get'](config_path, {})

  # shout loud and hefty if we do not know anything about the given host
  if len(config) == 0:
    raise Exception('Do not know nothing about a host named {0}'.format(name))

  return config


def container(name):
  '''
  Return the configuration of a specific container

  :param name:
    The canonical id of the container in question

  :return:
    Full configuration data structure

  '''
  config_path = 'containers:' + name
  config = __salt__['pillar.get'](config_path, {})

  # shout loud and hefty if we do not know anything about the given container
  if len(config) == 0:
    raise Exception('Do not know nothing about a container named {0}'.format(name))

  return config


def node_ip():
  '''
  Return the first ip4 address on the fqdn interface of this node

  :return:
    Ip4 address

  '''

  return __grains__['fqdn_ip4'][0]


def container_list(preselect=[]):
  '''
  Prepare a list of all containers in the same environment as the calling host

  :param preselect:
    Optional prepopulated list that would be returned in favor fo the calculated one

  :return:
    A list of container id's - either calculated or what was found in preselect
  '''
  if type(preselect) is str:
    preselect = preselect.split(',')

  if len(preselect) > 0:
    return preselect

  return sorted(__salt__['pillar.get']('containers', {}).keys())


def elastic():
  '''
  Provide elasticsearch configuration information

  :return:
    Configuration data structure

  '''

  result = {}

  defaults = __salt__['pillar.get']('elastic', {})
  node = __salt__['grains.get']('host', "none")
  result = __salt__['pillar.get']('containers:{0}:elastic'.format(node), defaults, True)

  allow_master = 'false'
  allow_data = 'false'

  for role in __salt__['grains.get']('roles', []):
    if role == 'elastic_master':
      allow_master = 'true'

    if role == 'elastic_data':
      allow_data = 'true'

  result['allow_master'] = allow_master
  result['allow_data'] = allow_data

  if 'memory_lock' in result:
    result['memory_lock'] = "true"
  else:
    result['memory_lock'] = "false"

  if 'elasticip' not in result:
    result['elasticip'] = __salt__['grains.get']('fqdn_ip4', "")[0]

  if 'data_dir' in result:
    result['data_dir'] = result['data_dir'].strip('/')

  if 'data_dirs' in result:
    singlepath = result['data_dir']
    new_data_dirs = []
    for subdir in result['data_dirs']:
      if subdir[0:1] == '/':
        new_data_dirs.append(subdir.strip('/'))
      else:
        new_data_dirs.append('{0}/{1}'.format(singlepath, subdir))
    result['data_dirs'] = new_data_dirs
  else:
    result['data_dirs'] = [result.get('data_dir', '/var/lib/elasticsearch')]

  return result


