from __future__ import absolute_import
import salt.client
import salt.runner
import salt.config
import logging
import cpillar

log = logging.getLogger(__name__)


def enlist(environment, test=False, force=False, execute=True, commission=True):
  '''
  Create a bash script on the maas server that does the enlisting of all machines belonging to
  the named salt environment.

  :param environment:
    Salt pillar environment that we want to enlist the machines for

  :param test:
    Dry run - only tell what would be done

  :param force:
    If a node exists already, force it to be deleted and recreated

  :param execute:
    Execute the script once it has been generated

  :param commission:
    Start commissioning of the machines once added

  :return:
    A state result dict
  '''

  _pillar = cpillar.fake_pillar(None, environment, '1nc', __opts__)
  defaults = _pillar.get('defaults', {})
  maas = defaults.get('maas', {})
  nodes = _pillar.get('hosts', {})
  cluster = maas.get('cluster', 'cde')
  domain = cpillar.dig(defaults, 'network:manage:domain', 'localnet')

  res = []
  for id, node in nodes.items():
    _node = {}
    _node['name'] = cpillar.dig(node, 'network:manage:fqdn')
    _node['mac'] = cpillar.dig(node, 'network:manage:mac')
    _node['arch'] = defaults.get('arch', 'amd64')
    _node['sub'] = maas.get('sub', '')
    _node['powertype'] = maas.get('powertype', 'ipmi')

    if _node['powertype'] == 'virsh':
      _node['poweraddress'] = cpillar.dig(node, 'network:console:poweraddress', cpillar.dig(node, 'network:console:ip4'))
    else:
      _node['poweraddress'] = cpillar.dig(node, 'network:console:ip4')

    _node['powerpass'] = maas.get('powerpass', '')
    _node['powerid'] = id
    _node['partitions'] = node.get('partitions', '')
    _node['zone'] = maas.get('zone', '')
    _node['maas'] = node.get('no_maas', False) is False
    res.append(_node)

  _state_pillar = {
    'enlist': {'nodes': res, 'domain': domain, 'cluster': cluster,
               'commission': commission,
               'execute': execute,
               'force_nodes': force}}

  if test:
    return _state_pillar

  target = 'maas-a1.cde.1nc'

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)
  staterun = client.cmd(target, 'state.sls', ['maas.enlist'], kwarg={'pillar': _state_pillar})

  ret = {'data': {target: staterun}}
  ret['data']['retcode'] = 0 if salt.utils.check_state_result(ret['data']) else 1

  return ret


def testme(environment, test=False):
  ret = {'name': 'testme', 'result': True, 'changes': {'environment': environment}, 'comment': 'Haha!'}
  return ret