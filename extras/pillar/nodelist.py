from __future__ import absolute_import

import random
import logging
import salt.utils.dictupdate as udict
import collections
import cpillar
import nodebase


log = logging.getLogger(__name__)


def _get_virt_mac(prefix):
  '''
  Return a virtual mac address. It will create three last three octets of a mac address,
  combine it with the three given octets in the prefix and return it as a string

  :param prefix:
    The three prefix octets to use

  :return:
    mac address as string
  '''
  mac = [random.randint(0x00, 0xff),
         random.randint(0x00, 0xff),
         random.randint(0x00, 0xff)]

  return prefix + ':' + ':'.join(map(lambda x: "%02x" % x, mac))


def _get_node_ip4net(node_id, node, net):
  '''
  Select an ip4net for a node. Different strategies may be implemented over time.

  For now we have:
  - string: the ip4net value found in the net dict is a string. We assume it can be used
  straight and return it at once.

  - dict: the ip4net value is a dict and we assume that the keys of that dict are rack id's
  Return the value that matches the node's rackid

  :param node_id:
    The canonical name of the node as used in the config

  :param node:
    The merged node's configuration values, i.e group:node_id merged with the respective defaults

  :param net:
    As this function is called per network of the node the net parameter receives the network configuration
    that is currently being worked on

  :return:
    A string for a networks ip4net config setting

  '''

  ip4netvalue = net.get('ip4net')

  if type(ip4netvalue) is str:
    return ip4netvalue

  if isinstance(ip4netvalue, (dict, collections.OrderedDict)):
    return ip4netvalue.get(node.get('rackid'), '127.9.9.{0}/8')


def _get_veth_name(node_id, prefix):
  '''
  Create and return a veth name for a node. Veth names are meant to be used as names
  for veth type network interfaces mostly used in containers. We do not want the random
  generated ones. And they cannot be longer than 15 chars, otherwise the container
  wont start.

  :param node_id:
    The node name that we need a veth name for

  :param prefix:
    A prefix for the veth name - identifies the network this interface is used for

  :return:
    A string with the veth name

  '''

  suffix = ''
  maxlen = 15

  if len(prefix) > 0:
    maxlen -= 1

  hasdotat = node_id.find(".")
  if hasdotat > 0:
    node_id = node_id[0:hasdotat]

  hasdash = node_id.rfind("-")
  if hasdash > 0:
    suffix = node_id[hasdash + 1:]
    node_id = node_id[0:hasdash]
    maxlen -= 1

  shortlen = maxlen - len(prefix) - len(suffix)
  shortname = node_id[0:shortlen]

  return "-".join([prefix, shortname, suffix]).strip("-")


def _merge_defaults_for_group(defaults, group):
  '''
  Merge top level defaults into a groups defaults. Currently this will merge defaults:network
  into defaults:[group], but may be extended to do more in the future

  :param defaults:
    The full dict of pillar:defaults

  :param group:
    The name of the group as string

  :return:
    The dict for pillar:defaults:[group] with defaults:[xxx] merged into it

  '''
  # what we have in our tummy - the original defaults for the given group
  group_defaults = cpillar.dig(defaults, group, {})

  # the real network defaults
  master_defaults = {"network": cpillar.dig(defaults, "network", {})}

  # Merge but prioritise group values over default values
  return udict.merge_recurse(master_defaults, group_defaults)


def _merge_networks_for_node(node_id, node, defaults):
  '''
  Merge the defaults for a network into the network definitions for a node

  :param node_id:
    The id of the node that we are currently working on

  :param node:
    The node's network configuration

  :param defaults:
    The group defaults, i.e. merged pillar:defaults:[group]

  :return:
    The actual network configuration dict for the given node

  '''

  network = {}
  default_network = defaults.get('network', {})

  for id, config in node.get('network', {}).iteritems():

    # merge network configuration
    _net = udict.merge_recurse(default_network.get(id, {}), config)

    # merge common items into the network
    _net = udict.merge_recurse(default_network.get('common', {}), _net)

    # always create fqdn per network
    _net['fqdn'] = "{0}.{1}".format(node_id, _net.get('domain', 'local'))

    # Set a gateway
    # if config.has_key('gateway') and default_network.get(id, {}).has_key('gateway'):
    #   gateway = default_network.get(id, {}).get('gateway')
    #   log.debug('Node %s has gateway %s on network %s', node_id, gateway, id)
    #   if gateway is not None:
    #     _net['gateway'] = gateway
    # else:
    #   if _net.has_key('gateway'):
    #     del(_net['gateway'])

    if _net.has_key('nogateway') and _net.has_key('gateway'):
      del(_net['gateway'])

    # autogenerate a mac address if requested
    if _net.get('mac', '') == 'auto':
      _net['mac'] = _get_virt_mac(_net.get('macprefix', '02:aa:00'))

    if _net.get('type', '') == "veth":
      _net['vname'] = _get_veth_name(node_id, _net.get('vpref', 'vet'))

    _net['ip4net'] = _get_node_ip4net(node_id, node, _net)
    _net['cdir'] = _net.get('ip4net').split('/')[1]

    # take network ip4 in favour of node ip4
    _net['ip4'] = _net.get('ip4net').format(config.get('ip4', node.get('ip4'))).split('/')[0]

    # cleanup
    for field in ['vpref', 'macprefix']:
      if field in _net:
        del (_net[field])

    network[id] = _net

  return network


def _expand_mounts_for_node(node_fqdn, node_mounts):
  '''
  Mount strings can have placeholders that should be filled with the fqdn of the current node

  :param node_fqdn:
    Full name of the node

  :param node_mounts:
    Dict of all mount definitions

  :return:
    Same array as the input array but with placeholders replaces

  '''

  _mounts = {}
  for mid, mount in node_mounts.iteritems():
    local = '/' + mount['local'].format(node_fqdn).lstrip("/")
    remote = mount['remote'].format(node_fqdn).lstrip("/")
    _mounts[mid] = {'local': local, 'remote': remote}

  return _mounts


def _merge_lists_for_node(list_id, node, defaults):
  '''
  Merge two lists by adding nodes entries to the default entries

  :param list_id:
    The id of the list that should be merged

  :param node:
    The node configuration dict

  :param defaults:
    The default values configuration dict

  :return:
    The combined lists

  '''
  return defaults.get(list_id, []) + node.get(list_id, [])


def ext_pillar(minion_id, pillar, *args, **kwargs):
  '''
  Enrich the simple pillar by preparing proper structures for either hosts or containers.
  This is the central place to do all merge and calculation procedures needed to get the
  full configuration information for a node, which is either a host or a container

  :param minion_id:
    The id of the minion that is requesting this pillar

  :param pillar:
    The compiled pillar for the requesting minion - also processes the top file

  :param args:
    Unnamed positional args

  :param kwargs:
    Named args given

  :return:
    A dict witch will be merged with the original pillar, overwriting the existing elements.
    In the case of this external pillar will be

      {'hosts': [hostconfiguration], 'containers': [containerconfiguration] }

  '''

  nodebase_files = cpillar.dig(pillar, 'defaults:nodebase', [])
  nodebase_data = nodebase.data(nodebase_files, __opts__['file_buffer_size'])

  _nodes = {}
  for group in ["hosts", "containers"]:

    _nodebase_groupnodes = dict(nodebase_data.get(group, {}))

    _newgroupnodes = {}
    _groupnodes = cpillar.dig(pillar, group, {})
    _groupdefaults = _merge_defaults_for_group(pillar.get("defaults", {}), group)

    _netschema = cpillar.dig(_groupdefaults, 'network:schema', 'None')

    for nid, node_config in _groupnodes.iteritems():

      # merge the nodes config with the one from the nodebase
      config = udict.merge_recurse(_nodebase_groupnodes.get(nid, {}), node_config)

      # if we use racked schema, add rackid from node name
      if _netschema == 'racked' and 'rackid' not in config:
        config['rackid'] = 'rack{:0>2}'.format(nid.split('-').pop()[1:])

      _node = udict.merge_recurse(_groupdefaults, config)
      _node['network'] = _merge_networks_for_node(nid, config, _groupdefaults)

      _node['fqdn'] = cpillar.dig(_node, 'network:manage:fqdn')
      _node['hostname'] = nid
      _node['nature'] = group

      # TODO: remove when using 2015.8+
      # take special care about lists
      for mergelist in ['roles', 'packages']:
        if mergelist in config or mergelist in _groupdefaults:
          _node[mergelist] = _merge_lists_for_node(mergelist, config, _groupdefaults)

      if 'target' in _node:
        _node['target'] = '{0}.{1}'.format(_node['target'], cpillar.dig(_node, 'network:manage:domain'))

      if 'mole' not in _node:
        _node['mole'] = "hosts"

      if 'mount' in _node:
        _node['mount'] = _expand_mounts_for_node(_node.get('fqdn'), _node.get("mount", {}))

      _newgroupnodes[nid] = _node

      if _node['fqdn'] == minion_id:
        _nodes['local'] = _node

    _nodes[group] = _newgroupnodes

  return _nodes
