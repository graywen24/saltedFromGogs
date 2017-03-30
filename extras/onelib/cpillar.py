from __future__ import absolute_import
import salt.client
import salt.runner
import salt.config
import salt.loader
import logging

import salt.utils.dictupdate as udict

log = logging.getLogger(__name__)


def dig(pillar, path, default=None):
  '''
  Dig in a pillar structure for a deeper level value

  :param pillar:
    the structure to be searched - effectively a multi level dict

  :param path:
    the path to search as colon delimited string

  :param default:
    the value to return if path is not found

  :return:
    the value or default

  '''

  if len(path) is 0:
    return pillar

  return salt.utils.traverse_dict_and_list(pillar, path, default, ":")


def gen_networks(res, nodename, ip, active, mole, defaults, definitions):

  networks = {}

  for netid, settings in definitions.items():

    networks['active'] = active
    networks['mole'] = mole

    if defaults.get(netid,{}).has_key('domain'):

      if not networks.has_key(netid):
        networks[netid] = {}

      netdefinition = udict.merge_recurse(defaults.get(netid), definitions.get(netid))
      netdefinition = udict.merge_recurse(netdefinition, settings)

      networks[netid] = {'host': nodename + '.' + netdefinition.get('domain'),
                         'ip4': str(netdefinition.get('ip4net', '')).format(str(ip))}

      if netdefinition.has_key('mac'):
        networks['dhcp'] = netdefinition.get('mac')

  if len(networks) > 0:
    res[nodename] = networks

  return res


def fake_pillar(domain=None, saltenv=None, top="1nc", opts={}):

  if domain is None and saltenv is None:
    raise Exception("One parameter must be specified, either domain or saltenv!")
    return

  if domain is None:
    domain = saltenv + "." + top

  if saltenv is None:
    parts = domain.split('.')
    saltenv = parts[len(parts) - 2]

  fakehost = 'fakehost-xx.' + domain

  log.debug('fake_pillar: running domain %s in env %s', domain, saltenv)

  pillar = salt.pillar.Pillar(opts, {}, fakehost, saltenv)
  cpillar = pillar.compile_pillar()

  return cpillar


def minion_pillar(minion, path=None, pillarenv='base', default=None):

  __opts__ =   salt.config.master_config('/etc/salt/master')
  __grains__ = salt.loader.grains(__opts__)

  pillar = salt.pillar.Pillar(__opts__, __grains__, minion, pillarenv)

  top, terrors = pillar.get_top()
  penvs = pillar.top_matches(top)

  effective_penv = 'base'
  for penv in penvs.iterkeys():
    if penv != 'base':
      effective_penv = penv

  res = pillar.compile_pillar()

  if path is None:
    res['pillarenv'] = effective_penv
    return res

  res['pillarenv'] = effective_penv
  keys = path.split(':')
  for key in keys:
    if isinstance(res, dict):
      res = res.get(key, default)

  return res

