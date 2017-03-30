# Import salt modules
from __future__ import absolute_import

# Import salt libs
import salt.pillar
import salt.utils.minions
import salt.client

def up():
  '''
  Print a list of all of the minions that are up
  '''
  client = salt.client.LocalClient(__opts__['conf_file'])
  minions = client.cmd('*', 'test.ping', timeout=1)
  for minion in sorted(minions):
    print minion


def enlist(domain, select="", **kwargs):

  minion = '*.' + domain

  print "Running for minion " + minion

  saltenv = 'base'
  id_, grains, _ = salt.utils.minions.get_minion_data(minion, __opts__)
  if grains is None:
    grains = {'fqdn': minion, 'saltenv': saltenv}

  pl = salt.pillar.Pillar(
    __opts__,
    grains,
    id_,
    saltenv)

  compiled_pillar = pl.compile_pillar()

  minion = salt.minion.MasterMinion(__opts__)
  running = minion.functions['state.sls'](
    "maas.enlist",
    saltenv,
    None,
    None,
    pillar=compiled_pillar,
    pillarenv=None)

  ret = {'data': {minion.opts['id']: running}, 'outputter': 'highstate'}
  res = salt.utils.check_state_result(ret['data'])
  if res:
    ret['data']['retcode'] = 0
  else:
    ret['data']['retcode'] = 1
  return ret

