from __future__ import absolute_import
from operator import itemgetter
import time
import ipaddr
import salt.client
import salt.runner
import salt.config
import salt.utils
import logging
import cpillar

log = logging.getLogger(__name__)


def _get_arpa(ipnet):
  '''
  Reverse an IP4 address - just to be used as an in-addr.arpa thingy

  :param ipnet:
    IP4 address as string

  :return:
    the ipnet backwards

  '''
  octets = ipnet.split('.')
  return "%s.%s.%s.in-addr.arpa" % (octets[2], octets[1], octets[0])


def _get_nodes(pillar):
  '''
  Create a unified list of nodes from hosts and containers

  :param pillar:
    Compiled pillar for a minion

  :return:
    Dict containing all nodes
  '''

  res = pillar.get('hosts', {})
  res.update(pillar.get('containers', {}))

  return res


def _get_static_dns_records(dns_records, default_only=True, default_records=[]):

  _zones = {}
  for domain, records in dns_records.iteritems():

    if domain == "default" and default_only is False:
      continue

    if domain != "default" and default_only is True:
      continue

    for record in records:
      if domain not in _zones:
        _zones[domain] = list(default_records)

      dnskey, dnstype, dnsclass, dnsvalue = record.split(',', 4)
      _zones[domain].append('{:20} {:3} {:10} {}'.format(dnskey, dnstype, dnsclass, dnsvalue))

  return _zones


def gen_dns(environment, top="1nc", test=False):
  '''
  Function that creates the dns zone data for an environment and passes it to the corresponding state
  on the dns servers. The state will create the zone files and include them into the server coniguration

  CLI Example:

  .. code-block:: bash

      salt-run nodes.gen_dns dev

  :param environment:
    The environment you want the dns zone files be created for

  :param top:
    The top level domain if none is given in the pillar configuration for the environment/network

  :param test:
    If true, only return the data - do not call the states

  :return:
    If just for test, returns the data created. If run, it returns the state results

  '''
  _pillar = cpillar.fake_pillar(None, environment, top, __opts__)
  _nodes = _get_nodes(_pillar)

  # ensure that we have the same soa for all changed files
  # soa = {'serial': time.strftime('%Y%m%d%H%M%S')}
  serial = time.strftime('%s')

  # add static dns records first
  _dns_zone_default = _get_static_dns_records(cpillar.dig(_pillar, "defaults:dns:records", {})).get('default')
  _zones = _get_static_dns_records(cpillar.dig(_pillar, "defaults:dns:records", {}), False, _dns_zone_default)

  _soa = {}
  for id, node in _nodes.iteritems():

    # outer loop: iterate all networks
    for network, netdata in node.get('network', {}).iteritems():

      # dont handle that network at all if no domain is set ...
      if 'domain' not in netdata:
        continue

      domain = netdata.get('domain')
      arpa = _get_arpa(netdata.get('ip4'))

      if domain not in _zones:
        _zones[domain] = list(_dns_zone_default)

      _zones[domain].append('{:20} IN  {:10} {}'.format(id, "A", netdata.get('ip4')))

      for cname in netdata.get('cnames', []):
        _zones[domain].append('{:20} IN  {:10} {}'.format(cname, "CNAME", id))

      if arpa not in _zones:
        _zones[arpa] = list(_dns_zone_default)

      _zones[arpa].append('{:<20} IN  {:10} {}.'.format(node.get('ip4'), "PTR", netdata.get('fqdn')))

  for zone in _zones.keys():
    if zone.endswith('arpa'):
      _soa[zone] = {'type': 'arpa', 'serial': serial}
    else:
      _soa[zone] = {'type': 'zone', 'serial': serial}

  _statepillar = {"zones": _zones, "soa": _soa }

  if test:
    return _statepillar

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)
  opt = {'expr_form': 'compound'}
  _t = 'micros-a?.cde.1nc and G@roles:dns'
  staterun = client.cmd(_t, 'state.sls', ['bind.zones'], kwarg={'pillar': _statepillar}, **opt)

  return staterun


def gen_dns_all(top="1nc", test=False):
  '''
  Call gen_dns for all environments defined in the environments pillar

  CLI Example:

  .. code-block:: bash

      salt-run nodes.gen_dns_all

  :param top:
    The top level domain if none is given in the pillar configuration for the environment/network

  :param test:
    If true, only return the data - do not call the states

  :return:
    If just for test, returns the data created. If run, it returns the state results
  '''

  _pillar = cpillar.fake_pillar(None, "cde", "1nc", __opts__)
  envdata = _pillar.get('environments')

  res = {}
  for env in envdata['active'].keys():
    res[env] = gen_dns(env, top, test)

  return res


def gen_dhcp(environment, top="1nc", test=False):
  '''
  Function that creates the dhcp subnet data for an environment and passes it to the corresponding state
  on the dhcp servers. The state will create the subnet files and include them into the server configuration.

  CLI Example:

  .. code-block:: bash

      salt-run nodes.gen_dhcp dev

  :param environment:
    The environment you want the dhcp subnet files be created for

  :param top:
    The top level domain if none is given in the pillar configuration for the environment/network

  :param test:
    If true, only return the data - do not call the states

  :return:
    If just for test, returns the data created. If run, it returns the state results
  '''

  _pillar = cpillar.fake_pillar(None, environment, top, __opts__)
  _defaults = _pillar.get('defaults', {})
  _nodes = _pillar.get("hosts", {})
  _network = cpillar.dig(_pillar, "defaults:network:manage", {})
  _schema = cpillar.dig(_pillar, "defaults:network:schema", None)

  nameservers = ", ".join(cpillar.dig(_defaults, "dns:servers", ['127.10.10.1']))

  if _schema == 'racked':
    _ipnetwork = _network.get('ip4net', {'rack01': '127.10.10.{0}/24'}).get('rack01').format('0')
  else:
    _ipnetwork = _network.get('ip4net', '127.10.10.{0}/24').format('0')

  _subnet = {}
  _subnet['group'] = environment
  _subnet['address'] = ipaddr.IPv4Network(_ipnetwork).network.__str__()
  _subnet['netmask'] = ipaddr.IPv4Network(_ipnetwork).netmask.__str__()
  _subnet['interface'] = _network.get('phys', 'eth0')


  # TODO: define currently hardcoded options in config or deduct from config
  _options = {}
  _options["subnet-mask"] = _subnet['netmask']
  _options["broadcast-address"] = ipaddr.IPv4Network(_ipnetwork).broadcast.__str__()

  _options["domain-name-servers"] = nameservers
  _options["ntp-servers"] = ", ".join(cpillar.dig(_defaults, "ntp-servers:internal", {'localhost': '127.10.10.1'}).values())

  _options["domain-search"] = '"' + _network.get("domain", "1nc") + '"'
  _options["domain-name"] = '"' + _network.get("domain", "1nc") + '"'
  _options["routers"] = _network.get('gateway', '127.10.10.1')

  # host loop
  _hosts = []
  for id, node in _nodes.iteritems():

    # if the node does not have the network we need, hopp over
    if "manage" not in node['network']:
      continue

    _host = {}
    _host['name'] = id
    _host['ip'] = cpillar.dig(node, "network:manage:ip4", "")
    _host['fqdn'] = cpillar.dig(node, "network:manage:fqdn", "")
    _host['mac'] = cpillar.dig(node, "network:manage:mac", "")
    _hosts.append(_host)

  _hosts.sort(key=itemgetter('ip'))
  _statepillar = {'dhcpd': {'subnet': _subnet, 'options': _options, 'hosts': _hosts}}

  if test:
    return _statepillar

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)
  _t = 'micros-a?.cde.1nc and G@roles:dhcp'
  staterun = client.cmd(_t, 'state.sls', ['dhcpd.subnet'], expr_form="compound", kwarg={'pillar': _statepillar})

  return staterun


def gen_dhcp_all(top="1nc", test=False):
  '''
  Call gen_dhcp for all environments defined in the environments pillar

  CLI Example:

  .. code-block:: bash

      salt-run nodes.gen_dhcp_all

  :param top:
    The top level domain if none is given in the pillar configuration for the environment/network

  :param test:
    If true, only return the data - do not call the states

  :return:
    If just for test, returns the data created. If run, it returns the state results
  '''

  _pillar = cpillar.fake_pillar(None, "cde", "1nc", __opts__)
  envdata = _pillar.get('environments')

  res = {}
  for env in envdata['active'].keys():
    res[env] = gen_dhcp(env, top, test)

  return res

