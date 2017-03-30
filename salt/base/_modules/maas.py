'''
Allow the MaaS API being used from a saltstack execution module

'''

# Import python libs
from __future__ import absolute_import
import salt

from apiclient.maas_client import (
  MAASClient,
  MAASDispatcher,
  MAASOAuth,
)
from salt.exceptions import CommandExecutionError
import json
import urllib2
import urllib
from base64 import b64encode

class NODE_STATUS:
  """The vocabulary of a `Node`'s possible statuses."""
  #: A node starts out as NEW (DEFAULT is an alias for NEW).
  DEFAULT = 0

  #: The node has been created and has a system ID assigned to it.
  NEW = 0
  #: Testing and other commissioning steps are taking place.
  COMMISSIONING = 1
  #: The commissioning step failed.
  FAILED_COMMISSIONING = 2
  #: The node can't be contacted.
  MISSING = 3
  #: The node is in the general pool ready to be deployed.
  READY = 4
  #: The node is ready for named deployment.
  RESERVED = 5
  #: The node has booted into the operating system of its owner's choice
  #: and is ready for use.
  DEPLOYED = 6
  #: The node has been removed from service manually until an admin
  #: overrides the retirement.
  RETIRED = 7
  #: The node is broken: a step in the node lifecyle failed.
  #: More details can be found in the node's event log.
  BROKEN = 8
  #: The node is being installed.
  DEPLOYING = 9
  #: The node has been allocated to a user and is ready for deployment.
  ALLOCATED = 10
  #: The deployment of the node failed.
  FAILED_DEPLOYMENT = 11
  #: The node is powering down after a release request.
  RELEASING = 12
  #: The releasing of the node failed.
  FAILED_RELEASING = 13
  #: The node is erasing its disks.
  DISK_ERASING = 14
  #: The node failed to erase its disks.
  FAILED_DISK_ERASING = 15


# Django choices for NODE_STATUS: sequence of tuples (key, UI
# representation).
NODE_STATUS_CHOICES = (
  (NODE_STATUS.NEW, "New"),
  (NODE_STATUS.COMMISSIONING, "Commissioning"),
  (NODE_STATUS.FAILED_COMMISSIONING, "Failed commissioning"),
  (NODE_STATUS.MISSING, "Missing"),
  (NODE_STATUS.READY, "Ready"),
  (NODE_STATUS.RESERVED, "Reserved"),
  (NODE_STATUS.ALLOCATED, "Allocated"),
  (NODE_STATUS.DEPLOYING, "Deploying"),
  (NODE_STATUS.DEPLOYED, "Deployed"),
  (NODE_STATUS.RETIRED, "Retired"),
  (NODE_STATUS.BROKEN, "Broken"),
  (NODE_STATUS.FAILED_DEPLOYMENT, "Failed deployment"),
  (NODE_STATUS.RELEASING, "Releasing"),
  (NODE_STATUS.FAILED_RELEASING, "Releasing failed"),
  (NODE_STATUS.DISK_ERASING, "Disk erasing"),
  (NODE_STATUS.FAILED_DISK_ERASING, "Failed disk erasing"),
)


# Set up logging
import logging

logger = logging.getLogger(__name__)

# define the location of the maas region admin tool
maasra = '/usr/sbin/maas-region-admin'

# temporary storage for the client session
_mclient = None


def __virtual__():
  '''
  Ensure that the maas client tools are installed.
  '''
  if salt.utils.which('maas-region-admin'):
    return True
  return False


def _matches(haystack, needles):

  '''
  Look into haystack and try to match any needle values. For the first needle found where
  the value does not match the function returns false.
  :param haystack:
    A dict to search in

  :param needles:
    A dict with key value pairs that are being searched and compared in the haystack

  :return:
    True if all needle values match in the haystack, false otherwise
  '''
  for _key, _value in needles.iteritems():

    paths = _key.split('.', 2)
    if len(paths) > 1:
      if haystack.has_key(paths[0]):
        logger.debug('Decending into key %s', paths[0])
        if not _matches(haystack.get(paths[0]), {paths[1]: _value}):
          return False

    if haystack.has_key(_key):
      logger.debug('Checking %s: %s != %s', _key, _value, haystack.get(_key))
      if haystack[_key] != _value:
        return False

  return True


def _get_status_text(sid):
  '''
  Return the text for a node status

  :param sid:
    Status id that need translation

  :return:
    String with the status description
  '''

  for status in NODE_STATUS_CHOICES:
    if status[0] == sid:
      return status[1]

  return 'INVALID'


def _get_status_info(nodeinfo, fieldlist=[]):
  '''
  Take a single node info structure and reduce it to the most important information
  - if it contains apicode its an error object - return the original data
  - else return the fields in fieldlist, transform status and substatus to text

  :param nodeinfo:
    A nodeinfo data structure returned by the MaaS server

  :return:
    A dict with reduced node information

  '''
  info = {}
  fieldlist.extend(['status', 'statustext', 'substatus', 'substatustext'])

  if nodeinfo.has_key('apicode'):
    return nodeinfo

  if not nodeinfo.has_key('statustext'):
    nodeinfo['statustext'] = _get_status_text(nodeinfo['status'])
    nodeinfo['substatustext'] = _get_status_text(nodeinfo['substatus'])

  for field in fieldlist:
    if nodeinfo.has_key(field):
      info[field] = nodeinfo[field]

  return info


def _get_status_infos(nodeinfos, fieldlist=[]):
  '''
  Reduce a dict of node info data into simple node information

  :param nodeinfos:
    A dict with the node name as the key and containing a node info structure as the value

  :return:
    A dict with reduced node information per contained node
  '''
  _newlist = {}

  for _name, _node in nodeinfos.iteritems():
    if _node is None:
      _newlist[_name] = {}
    else:
      _newlist[_name] = _get_status_info(_node, fieldlist)

  return _newlist


def _getclient(url=u'http://localhost/MAAS/api/1.0/'):
  '''
  Use the MAAS apiclient to aquire a session with the Maas API
  :param url:
    How to connect to the Maas server. As we require the Maas tools
    installed on the executing machine, this can be the localhost by default.

  :return:
    A MAASClient object
  '''
  global _mclient
  if _mclient is None:
    consumer_key, token, secret = key('root').split(':', 3)
    auth = MAASOAuth(consumer_key, token, secret)
    dispatch = MAASDispatcher()
    _mclient = MAASClient(auth, dispatch, url)

  return _mclient


def _mget(path):
  '''
  Use the MAASClient to run a get request against the Maas API

  :param path:
    Path of the request added to the base API uri

  :return:
    Result of the request as a dict
  '''
  try:
    resp = _getclient().get(path).read()
    return json.loads(resp)
  except urllib2.HTTPError as e:
    logger.error("HTTP error: " + e.read())
    return {'apicode': e.getcode(), 'apimessage': e.msg}
  except ValueError:
    logger.debug('We did not get a json back - returning plain response.')
    return resp

  return


def _mdelete(path):
  '''
  Use the MAASClient to run a delete request against the Maas API

  :param path:
    Path of the request added to the base API uri

  :return:
    Result of the request as a dict
  '''
  try:
    resp = _getclient().delete(path).read()
    return json.loads(resp)
  except urllib2.HTTPError as e:
    logger.error("HTTP error: " + e.read())
    return {'apicode': e.getcode(), 'apimessage': e.msg}
  except ValueError:
    logger.debug('We did not get a json back - returning plain response.')
    return resp

  return


def _mpost(path, op, **kwargs):
  '''
  Use the MAASClient to run a post request against the Maas API

  Example:
    _mpost('nodegroups', 'list', name=somenode.name.thing)

  :param path:
    Path of the request added to the base API uri

  :param op:
    Operation flag

  :param kwargs:
    Additional params for the request, especially the post parameters as key/value pairs

  :return:
    Result of the request as a dict
  '''

  if len(kwargs) == 0:
    kwargs['dummy'] = ""

  path = path.strip("/") + u"/"
  try:
    resp = _getclient().post(path, op, **kwargs).read()
    logger.debug('POST result: %s', resp)
    return json.loads(resp)
  except urllib2.HTTPError as e:
    logger.error("HTTP error: %s", e)
    return {'apicode': e.getcode(), 'apimessage': e.msg}
  except ValueError:
    logger.debug('We did not get a json back - returning plain response.')
    return resp

  return


def _mput(path, **kwargs):
  '''
  Use the MAASClient to run a put request against the Maas API

  :param path:
    Path of the request added to the base API uri

  :param kwargs:
    Additional params for the request

  :return:
    Result of the request as a dict
  '''
  path = path.strip("/") + u"/"
  try:
    resp = _getclient().put(path, **kwargs).read()
    logger.debug('PUT result: %s', resp)
    return json.loads(resp)
  except urllib2.HTTPError as e:
    logger.error("HTTP error: " + e.read())
    return {'apicode': e.getcode(), 'apimessage': e.msg}
  except ValueError:
    logger.debug('We did not get a json back - returning plain response.')
    return resp

  return


def key(name):
  '''
  Retrieve the Maas key for the named user

  CLI Example:

  .. code-block:: bash

      salt maas maas.key root

  :param name:
    Name of the user we want the key for

  :return:
    Key as a string
  '''
  apikey = __salt__['cmd.run_all']('{0} apikey --username={1}'.format(maasra, name))
  if not apikey['retcode'] == 0:
    raise CommandExecutionError(apikey['stderr'])

  return apikey['stdout']


def networks():
  '''
  Get all networks from Maas Server

  CLI Example:

  .. code-block:: bash

      salt maas maas.networks

  :return:
    Networks as dict
  '''
  return _mget(u'networks/')


def nodegroups():
  '''
  Get all nodegroups from Maas Server. Actually, some versions of Maas call this cluster.

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroups

  :return:
    Nodegroups as list of dicts
  '''
  return _mget(u'nodegroups/?op=list')


def nodegroup(ngid, details=False):
  '''
  Get all fields for a specific nodegroup from Maas Server.

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroups 546a2369-1b7b-44ce-a70c-b43c75c49079
      salt maas maas.nodegroups 546a2369-1b7b-44ce-a70c-b43c75c49079 details=True

  :param ngid:
    Nodegroup id - the uuid of the nodegroup that was retrieved using the nodegroup function

  :param details:
    Retrieve details for this nodegroup - whatever that means :)

  :return:
    Nodegroup as dict
  '''
  op = ''
  if details:
    op = 'op=details'
  return _mget(u'nodegroups/{}/?{}'.format(ngid, op))


def nodegroup_by_name(name):
  '''
  Get the uuid of the specified nodegroup from Maas Server.

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_by_name cde

  :param name:
    Name of the nodegroup that we want the information for

  :return:
    Nodegroup uuid (ngid)
  '''
  ngroups = nodegroups()
  for ngroup in ngroups:
    if ngroup.get('cluster_name').lower() == name.lower():
      return ngroup.get('uuid')

  return None


def nodegroup_by_ip(ipaddr):
  '''
  Get the uuid of the nodegroup that is bind to the given ip address from Maas Server.

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_by_ip 192.168.48.100

  :param ipaddr:
    This is the ip of the interface the cluster is bound to - as you run this command on a
    maas server, this should be the main ip of the servers management network

  :return:
    Nodegroup uuid (ngid)
  '''
  ngroups = nodegroups()
  for ngroup in ngroups:
    uuid = ngroup.get('uuid')
    for iface in nodegroup_interfaces(uuid):
      if iface.get('ip') == ipaddr:
        return uuid

  return None


def nodegroup_bootimages_import(name):
  '''
  Start the import of bootimages on the given nodegroup/cluster

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_bootimages_import cde

  :param name:
    The name of the nodegroup (cluster)

  :return:
    A string telling you the import has been started
  '''
  ngid = nodegroup_by_name(name)
  return _mpost(u'nodegroups/', u'import_boot_images', uuid=ngid)


def nodegroup_bootimages(name):
  '''
  List the available bootimages for the given nodegroup/cluster

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_bootimages cde

  :param name:
    The name of the nodegroup (cluster)

  :return:
    A list of dicts containing information about available boot images
  '''
  ngid = nodegroup_by_name(name)

  if ngid is None:
    return None

  return _mget(u'nodegroups/{}/boot-images/'.format(ngid))


def nodegroup_save(ngid, **kwargs):
  '''
  Save changes to a nodegroup. Only the allowed fields can be changed, so obviously not the uuid, but the cluster_name,
  the name and the status. Refer to nodegroup to see the fields available.

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_save 546a2369-1b7b-44ce-a70c-b43c75c49079 cluster_name=CDE

  :param ngid:
    Nodegroup uuid

  :param cluster_name:
    Set a new cluster name

  :param name:
    Set a new dns zone name - which is usually a domain

  :param status:
    Set a new status

  :return:
    A dict containing the new nodegroup information
  '''
  return _mput(u'nodegroups/{}/'.format(ngid), **kwargs)


def nodegroup_interface_by_name(name, ifname):
  '''
  Retrieve information about a specific interface on a specific nodegroup/cluster by the name of the interface

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_interface_by_name cde klaro

  :param name:
    The name of the nodegroup/cluster

  :param ifname:
    The name of the interface

  :return:
    Dict of information about this interface
  '''
  ngid = nodegroup_by_name(name)
  return _mget(u'nodegroups/{}/interfaces/{}/'.format(ngid, ifname))


def nodegroup_interface_by_ip(name, ipaddr):
  '''
  Retrieve information about a specific interface on a specific nodegroup/cluster by the ip address of the interface

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_interface_by_ip cde 192.168.48.100

  :param name:
    The name of the nodegroup/cluster

  :param ipaddr:
    The ip of the interface

  :return:
    Dict of information about this interface
  '''
  ngid = nodegroup_by_name(name)
  for iface in nodegroup_interfaces(ngid):
    if iface.get('ip') == ipaddr:
      return iface

  return None


def nodegroup_interfaces(name):
  '''
  Retrieve a list of interfaces for a nodegroup/cluster

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_interface_by_name cde klaro

  :param name:
    The name of the nodegroup/cluster

  :return:
    A list of dicts with information about the nodegroup/clusters interfaces
  '''
  ngid = nodegroup_by_name(name)
  return _mget(u'nodegroups/{}/interfaces/?op=list'.format(ngid))


def nodegroup_interface_save(name, ifname, **kwargs):
  '''
  Save changes to a nodegroups interface . Only the allowed fields can be changed. Check nodegroup_interfaces
  about the fields that can be changed.

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodegroup_interface_save cde klaro interface=eth0 subnet_mask=255.255.0.0

  :param name:
    Name of the nodegroup/cluster

  :param ifname:
    Name of the interface to save

  :param broadcast_ip:
          192.168.48.255

  :param interface:
          eth0

  :param ip:
          192.168.48.100

  :param ip_range_high:
          None

  :param ip_range_low:
          None

  :param management:
          0

  :param name:
          klaro

  :param static_ip_range_high:
          None

  :param static_ip_range_low:
          None

  :param subnet_mask:
          255.255.255.0

  :return:
    A dict containing the changed interface information
  '''

  ngid = nodegroup_by_name(name)
  return _mput(u'nodegroups/{}/interfaces/{}/'.format(ngid, ifname), **kwargs)


def tags(short=False):
  '''
  Get a list of tags defined on the Maas server

  CLI Example:

  .. code-block:: bash

      salt maas maas.tags True

  :param short:
    If True, only a list of the tag names is returned

  :return:
    A list of dicts or just a list, if short is True
  '''

  tags_full = _mget(u'tags/?op=list')

  if short is False:
    return tags_full

  tags_short = []
  for tag in tags_full:
    tags_short.append(tag.get('name'))

  return tags_short


def nodes():
  '''
  Retrieve all nodes available in a Maas instance

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodes

  :return:
    A list of dicts
  '''
  return _mget(u'nodes/?op=list')


def nodes_list(fields=None, **kwargs):
  '''
  List all nodes, using the fqdn as a key. All or only the fields in the fields parameter list are
  returned. You can filter by any field giving a key value pair for the desired value to filter by.
  This function also returns statustext and substatustext, so you can use it for nice displays :)

  :param fields:
    Comma separeted list of fields to return - no spaces :)

  :param kwargs:
    Add and key value pair as filter. All values must match to have a record returned

  :return:
    A dict of node information with the nodes hostname as key
  '''
  _fields = []
  if fields is not None:
    _fields = fields.split(',')

  _list = {}

  for _node in nodes():
    _new = {}
    fqdn = _node.get('hostname', 'MISSING')

    _node['statustext'] = _get_status_text(_node['status'])
    _node['substatustext'] = _get_status_text(_node['substatus'])

    if fields is None:
      _list[fqdn] = _node
      continue

    if not _matches(_node, kwargs):
      continue

    for _field in _fields:
      if _node.has_key(_field):
        _new[_field] = _node[_field]

    _list[fqdn] = _new

  return _list


def nodes_status(zone=None):
  _nodelist = {}
  _kwargs = {'fields': 'status,substatus'}

  if zone is not None:
    _kwargs['zone.name'] = zone

  for _name, _status in nodes_list(**_kwargs).iteritems():
    _nodelist[_name] = _get_status_info(_status)

  return _nodelist


def node(nid, details=False):
  '''
  Retrieve information for the node given by id

  CLI Example:

  .. code-block:: bash

      salt maas maas.node node-9cee9894-4dee-11e6-826c-00ee1e4178bf
      salt maas maas.node node-9cee9894-4dee-11e6-826c-00ee1e4178bf True

  :param nid:
    Node ID for the node the information is requested for

  :param details:
    List more details for the node. This is a BSON formatted xml output
    containing lshw stuff

  :return:
    Dict of node information or some weird xml content
  '''

  op = ''
  if details:
    op = '?op=details'
  return _mget(u'nodes/{}/{}'.format(nid, op))


def node_by_name(name=None, fields=None):
  '''
  Retrieves information about a single node by its node name

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_by_name sample.host.dom
      salt maas maas.node_by_name sample.host.dom all
      salt maas maas.node_by_name sample.host.dom zone,memory,cpu_count

  :param name:
    The name of the node, mostly its fqdn

  :param fields:
    Fields to return. If empty, only the system_id will be returned. If 'all' is given,
    all fields will be returned. If a comma separated list of fieldnames is given, only
    those fields and the system_id will be returned

  :return:
    A single dict
  '''

  _nodes = nodes()
  _node = None

  for node in _nodes:

    if name is not None and node.get('hostname').lower() != name.lower():
      continue

    _node = {'system_id': node.get('system_id')}

    if fields == 'all':
      _node.update(node)
    elif fields is not None:
      _fields = fields.split(',')
      for field in _fields:
        _node[field] = node.get(field)

  return _node


def nodes_by_zone(zone=None, fields=None):
  '''
  Retrieves information about all nodes in a zone

  CLI Example:

  .. code-block:: bash

      salt maas maas.nodes_by_zone homezone
      salt maas maas.nodes_by_zone homezone all
      salt maas maas.nodes_by_zone homezone zone,memory,cpu_count

  :param zone:
    The name of the zone you want the nodes to be listed for

  :param fields:
    Fields to return. If empty, only the system_id will be returned. If 'all' is given,
    all fields will be returned. If a comma separated list of fieldnames is given, only
    those fields and the system_id will be returned

  :return:
    A dict of dicts where the top level key is the name of the node

  '''
  _nodes = nodes()

  _nodelist = {}
  for node in _nodes:

    _nodezone = node.get('zone')

    if zone is not None and _nodezone.get('name').lower() != zone.lower():
      continue

    _node = {'system_id': node.get('system_id')}

    if fields == 'all':
      _node.update(node)
    elif fields is not None:
      _fields = fields.split(',')
      for field in _fields:
        _node[field] = node.get(field)

    _nodelist[node.get('hostname')] = _node

  return _nodelist


# def node_create(name, nodegroup, arch, subarch, mac, powertype):
#
#   params = {
#     'architecture': arch,
#     'subarchitecture': subarch,
#     'mac_addresses': mac,
#     'hostname': name,
#     'power_type': powertype,
#     'autodetect_nodegroup': 'False',
#     'nodegroup': nodegroup
#   }
#
#   return _mpost(u'nodes/', u'new', **params)


def node_power_parameters(name):
  '''
  Return the power parameters configured for a specific node or all nodes in a zone

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_power_parameters homezone
      salt maas maas.node_power_parameters sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    A dict of power parameters per node
  '''
  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mget(u'nodes/{}/?op=power_parameters'.format(node_info.get('system_id')))
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mget(u'nodes/{}/?op=power_parameters'.format(_node.get('system_id')))

  return res


def node_power_on(name, userdata=None):
  '''
  Power on a specific node or all nodes in a zone

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_power_on homezone
      salt maas maas.node_power_on sample.host.dom [some userdata string]

  :param name:
    The name of a node or the name of a zone

  :param userdata:
    This is a string blob handled as user_data and send to the machine. It is expected to be
    a valid and executable binary or script - it will get base64 encoded. This file is executed
    by cloud_init when the node is turned on. After deployment, this file will be executed when the
    new node comes up for the first time. If ommitted in subsequent power on statements, the existing
    userdata will be reset to null. You can use this parameter only when the name is a machine,
    not a zone.

  :return:
    Nothing or a dict of error messages :)
  '''
  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mpost(u'nodes/{}/'.format(node_info.get('system_id')), u'start')
  else:
    params = {}
    if userdata is not None:
      params['user_data'] = b64encode(userdata.__str__())

    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mpost(u'nodes/{}/'.format(_node.get('system_id')), u'start', **params)

  return _get_status_infos(res)


def node_power_off(name):
  '''
  Power off a specific node or all nodes in a zone

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_power_off homezone
      salt maas maas.node_power_off sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    Nothing or a dict of error messages :)
  '''
  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mpost(u'nodes/{}/'.format(node_info.get('system_id')), u'stop', data='{}')
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mpost(u'nodes/{}/'.format(_node.get('system_id')), u'stop', data='{}')

  return _get_status_infos(res)


def node_power_state(name):
  '''
  Return the power state of a single node or all nodes in a zone from the current MaaS status. It
  only reads the state currently known to the MaaS server from its database.

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_power_state homezone
      salt maas maas.node_power_state sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    A dict with the node name as key and the power state as the value
  '''

  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mget(u'nodes/{}/'.format(node_info.get('system_id')))
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mget(u'nodes/{}/'.format(_node.get('system_id')))

  return _get_status_infos(res, ['power_state'])


def node_power_state_query(name):
  '''
  Return the power state of a single node or all nodes in a zone. This command actually queries
  the node for its power state and can take some time. It also clobbers the servers threadpool. So
  use it with care.

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_power_state_query homezone
      salt maas maas.node_power_state_query sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    A dict with the node name as key and the power state as the value
  '''

  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mget(u'nodes/{}/?op=query_power_state'.format(node_info.get('system_id'))).get('state', 'UNKNOWN!')
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mget(u'nodes/{}/?op=query_power_state'.format(_node.get('system_id'))).get('state', 'UNKNOWN!')

  return res


def node_commission(name):
  '''
  Start commissioning for a specific node or all nodes in a zone.

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_commission homezone
      salt maas maas.node_commission sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    A dict of call results
  '''

  logger.debug('Received commissioning request: name=%s', name)

  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mpost(u'nodes/{}'.format(node_info.get('system_id')), u'commission')
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mpost(u'nodes/{}'.format(_node.get('system_id')), u'commission')

  return _get_status_infos(res)


def node_abort(name):
  '''
  Abort current operation for a node or a zone.

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_abort homezone
      salt maas maas.node_abort sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    A dict of call results
  '''

  logger.debug('Received abort request: name=%s', name)

  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mpost(u'nodes/', u'abort', name=node_id)
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mpost(u'nodes/', u'abort', name=_node)

  return _get_status_infos(res)



def node_acquire(name):
  '''
  Acquire a specific node or all nodes in a zone so that they can be powered on.
  Powering on an acquired node will start OS deployment. Actually, the UI action
  deploy is a combination of calling acquire and then power on.

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_acquire homezone
      salt maas maas.node_acquire sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    A dict of call results
  '''

  logger.debug('Received acquire request: name=%s', name)

  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mpost(u'nodes/', u'acquire', name=node_id)
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mpost(u'nodes/', u'acquire', name=name)

  return _get_status_infos(res)


def node_release(name):
  '''
  Release a specific node or all nodes in a zone so that they can be reused. The
  node will be in powered off state afterwards.

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_release homezone
      salt maas maas.node_release sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    A dict of call results
  '''

  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mpost(u'nodes/{}/'.format(node_info.get('system_id')), u'release')
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mpost(u'nodes/{}/'.format(_node.get('system_id')), u'release')

  return _get_status_infos(res)


def node_delete(name):
  '''
  Delete a specific node or all nodes in a zone. This removes all information about
  the deleted nodes from the MaaS database. The nodes have to be released first.

  CLI Example:

  .. code-block:: bash

      salt maas maas.node_delete homezone
      salt maas maas.node_delete sample.host.dom

  :param name:
    The name of a node or the name of a zone

  :return:
    A dict of call results
  '''

  res = {}
  if zone_exists(name):
    _idlist = nodes_by_zone(name)
    for node_id, node_info in _idlist.iteritems():
      res[node_id] = _mdelete(u'nodes/{}/'.format(node_info.get('system_id')))
  else:
    _node = node_by_name(name)
    if _node is not None:
      res[name] = _mdelete(u'nodes/{}/'.format(_node.get('system_id')))

  return res


def events(**kwargs):
  '''
  Get a list of events for an object or a list of objects. This is a query function.

  CLI Example:

  .. code-block:: bash

      salt maas maas.events hostname=ess-a2.cde.1nc
      salt maas maas.events zone=CDE fields=hostname,level

  :param parameters:
    You can filter the events by the following parameters
    hostname, mac_address, zone, level where level
    might be one of DEBUG, INFO, WARNING, CRITICAL, ERROR

  :param fields:
    If not given, all fields will be returned. You can select the fields you
    want to have returned as a comma separated list. The fields selected can
    be any of the usual output fields.

  :return:
    A list of events with the selected fields or None

  '''

  has_perrors = False
  a_params = ['hostname', 'mac_address', 'zone', 'level']
  fields = kwargs.get('fields')

  accepted = {'op': 'query'}
  for key, value in kwargs.iteritems():

    # ignore public standard parameters
    if key.startswith(('__', 'fields')):
      continue

    if key in a_params:
      accepted[key] = value
    else:
      has_perrors = True
      logging.error("Unknown parameter: %s", key)

  if has_perrors:
    return None

  params = urllib.urlencode(accepted, 1)
  records = _mget(u'events/?{}'.format(params))

  count = records.get('count')
  if count is None:
    logging.info("No records returned: %s", count)
    return None

  if fields is None:
    return records.get('events')

  fieldlist = fields.split(',')
  events = []
  for record in records.get('events'):
    _record = {}
    for field, value in record.iteritems():
      if field not in fieldlist:
        continue
      _record[field] = value

    if len(_record) > 0:
      events.append(_record)

  return events


def files():
  '''
  List all files from the file storage

  CLI Example:

  .. code-block:: bash

      salt maas maas.files

  :return:
    List of files

  '''
  return _mget(u'files/?op=list')


def users():
  '''
  List all users of the cluster

  CLI Example:

  .. code-block:: bash

      salt maas maas.users

  :return:
    List of dicts containing user information

  '''
  return _mget(u'users/')


def ssh_keys():
  '''
  List all ssh_keys for the current account

  CLI Example:

  .. code-block:: bash

      salt maas maas.ssh_keys

  :return:
    List of dicts containing ssh keys
  '''
  return _mget(u'account/prefs/sshkeys/?op=list')


def ssh_key_add(sshkey):
  '''
  Add the given ssh key to the current account

  CLI Example:

  .. code-block:: bash

      salt maas maas.ssh_key_add 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTKa7UsjWrjIeRD2pI+FzDySRva1aLjR4lE5OhXZh+q identwo-ed'

  HINT: MaaS only supports RSA/DSA keys - all other modern formats trigger a stupid error

  :return:
    None or error
  '''
  _mpost(u'account/prefs/sshkeys/', u'new', key=sshkey)


def ssh_key_del(kid):
  '''
  Delete a key from the current user account

  CLI Example:

  .. code-block:: bash

      salt maas maas.ssh_key_del 2

  :param kid:
    The key id of the key to delete

  :return:
    None or error
  '''
  _mpost(u'account/prefs/sshkeys/{}/'.format(kid), u'delete')


def zones(name=None):
  '''
  Get a list of all zone configurations on the maas server connected to

  CLI Example:

  .. code-block:: bash

      salt maas maas.zones
      salt maas maas.zones homezone

  :param name:
    Optional request the config for a specific zone by giving its name

  :return:
    A list of dicts or a single dict, if name is given
  '''

  _zones = _mget(u'zones/')

  if name is not None:
    for zone in _zones:
      logger.warning("Checking %s: %s", zone.get('name'), zone)
      if zone.get('name').lower() == name.lower():
        return zone

    return {}

  return _zones


def zone_exists(name):
  '''
  Check if a named zone exists

  CLI Example:

  .. code-block:: bash

      salt maas maas.zone_exists homezone

  :param name:
    The name of the zone you want to check

  :return:
    True if the zone exists, otherwise false
  '''
  return len(zones(name)) > 0


def configs():
  '''
  List all global configuration options for the current cluster.

  CLI Example:

  .. code-block:: bash

      salt maas maas.configs

  :return:
    Dict of configuration options
  '''
  opts = [
    'commissioning_distro_series',
    'default_osystem',
    'ports_archive',
    'http_proxy',
    'windows_kms_host',
    'enable_disk_erasing_on_release',
    'default_distro_series',
    'ntp_server',
    'dnssec_validation',
    'upstream_dns',
    'boot_images_auto_import',
    'enable_third_party_drivers',
    'kernel_opts',
    'main_archive',
    'maas_name'
  ]

  all = {}
  for name in opts:
    all[name] = config_get(name)

  return all


def config_get(name):
  '''
  Get the current value for the named configuration option

  CLI Example:

  .. code-block:: bash

      salt maas maas.config_get maas_name

  :param name:
    Name of the option to return

  :return:
    Dict of config information
  '''
  return _mget(u'maas/?op=get_config&name={}'.format(name))


def config_set(name, value):
  '''
  Set the new value for the named configuration option

  CLI Example:

  .. code-block:: bash

      salt maas maas.config_set maas_name newname

  :param name:
    Name of the option to set

  :param value:
    Value of the option to set

  :return:
    OK or None in case of an error
  '''
  return _mpost(u'maas/', u'set_config', name=name, value=value)


def boot_resources():
  '''
  List all boot resources. A boot resource describes how the actual images are
  organised - in sets. You can upload new images/resources from files.

  CLI Example:

  .. code-block:: bash

      salt maas maas.boot_resources

  :return:
    List of dicts with boot resource information
  '''
  return _mget(u'boot-resources/')


def boot_resource(bid):
  '''
  Retrieve information about a given boot resource.

  CLI Example:

  .. code-block:: bash

      salt maas maas.boot_resource 1

  :param bid:
    Boot resource id for the resource that shall be retrieved

  :return:
    Dict of boot resource information
  '''
  return _mget(u'boot-resources/{}/'.format(bid))


def boot_sources():
  '''
  List of all boot sources for this cluster. A boot source is a url to a provider
  for boot images. Auto-import happens from a boot source and during import boot
  resources are created.

  CLI Example:

  .. code-block:: bash

      salt maas maas.boot_sources

  :return:
    A dict with boot source information

  '''
  return _mget(u'boot-sources/')


def boot_source(bid):
  '''
  Retrieve information about a given boot source.

  CLI Example:

  .. code-block:: bash

      salt maas maas.boot_source 1

  :param bid:
    Boot resource id for the source that shall be retrieved

  :return:
    Dict of boot source information
  '''
  return _mget(u'boot-sources/{}/'.format(bid))


def boot_source_save(bid, url=None, keyring=None):
  '''
  Update a given boot source.

  CLI Example:

  .. code-block:: bash

      salt maas maas.boot_source_save 1 url=http://repo.cde.1nc/images/ephemeral-v2/releases/

  :param bid:
    Boot resource id for the source that shall be retrieved

  :param url:
    The url for this boot source

  :param keyring:
    The path and filename for the keyring to use on the MaaS server

  :return:
    Dict of boot source information
  '''

  params = {}
  if url is not None:
    params['url'] = url

  if keyring is not None:
    params['keyring_filename'] = keyring

  return _mput(u'boot-sources/{}/'.format(bid), **params)


def boot_source_selections(bid):
  '''
  List selections for a specific boot source, i.e. what kind of images to
  import from this source.

  CLI Example:

  .. code-block:: bash

      salt maas maas.boot_source_selections

  :param bid:
    The boot source that we want to see the selection information for

  :return:
    List of dicts with boot source selection information
  '''
  return _mget(u'boot-sources/{}/selections/'.format(bid))


def boot_source_selection(bid, sid):
  '''
  Retrieve a single selection for a specific boot source.

  CLI Example:

  .. code-block:: bash

      salt maas maas.boot_source_selection 1 1

  :param bid:
    The boot source that we want to see the selection information for

  :param sid:
    The id for the selection you want to retrieve

  :return:
    Dict with boot source selection information
  '''
  return _mget(u'boot-sources/{}/selections/{}/'.format(bid, sid))


def boot_images(cluster):
  '''
  Calls nodegroup_bootimages
  '''
  return nodegroup_bootimages(cluster)

