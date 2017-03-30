# Import salt modules
from __future__ import absolute_import
import salt.client
import salt.runner
import salt.config
import salt.utils
from salt.exceptions import SaltInvocationError

import logging
import cpillar

log = logging.getLogger(__name__)

def _get_wheel():
  '''
  Acquire a wheel client

  :return:
    A wheel client object to work with
  '''
  opts = salt.config.master_config(__opts__.get('conf_file'))
  opts['output'] = 'quiet'
  return salt.wheel.WheelClient(opts)

def _convert_odict(candidate):
  '''
  Convert ordered dict into an ordinary dict, only if it actually is an odict.
  This function is recursive and converts all contained odicts too.

  :param candidate:
    Conversion candiate - a data structure as odict

  :return:
    The converted dict
  '''

  if type(candidate) in ['salt.utils.odict.OrderedDict']:
    replacer = dict(candidate)
  else:
    replacer = candidate

  keys = candidate.keys()
  for key in keys:
    value = candidate.get(key)
    print type(value)
    if type(value) in ['salt.utils.odict.OrderedDict', 'dict']:
      replacer[key] = _convert_odict(value)

  return replacer


def _get_master_pillar(full_path, default=None):

  '''
  This function instantiates a masterminion and compiles its
  pillar data. Returns either the pillar or parts of it.

  Remember pillar is compiled based on the pillar top file. So
  you might not get the full pillar back - the restriction is that
  the salt id of the master will be fqdn.of.host_master. Your
  targets in the top file need to match that!

  :param full_path:
    Path to the specific pillar item you want to be returned

  :param default:
    What to return if the data at path is not found

  :return:
    Returns a dict with the requested pillar data
  '''

  opts = salt.config.master_config('/etc/salt/master')
  opts['quiet'] = True
  opts['file_client'] = 'local'

  minion = salt.minion.MasterMinion(opts)
  _pillar = minion.functions['pillar.items']()

  data = cpillar.dig(_pillar, full_path, default)

  # Channel through json to get clean dict instead of odict
  import json
  data_clean = json.loads(json.dumps(data))

  return data_clean


def _minion_key_wrapper(keys):
  '''
  Returns a script to create the given keys on the target minion, where
  the script is run. It is meant to be used as the user_data parameter
  for the MaaS deployment.

  :param keys:
    A dict containting the private and public key for the minion

  :return:
    A shell script as string
  '''

  template = '''#!/bin/sh

set -e
echo "salt init: Ensuring pki storage is available ..."
mkdir -p /etc/salt/pki/minion
chmod 700 /etc/salt/pki/minion

echo "salt init: Installing public key ..."
cat << EOF > /etc/salt/pki/minion/minion.pub
{}
EOF
chmod 644 /etc/salt/pki/minion/minion.pub

echo "salt init: Installing private key ..."
cat << EOF > /etc/salt/pki/minion/minion.pem
{}
EOF
chmod 400 /etc/salt/pki/minion/minion.pem

echo "salt init: Enable salt minion ..."
mv /root/salt-minion.conf /etc/init/salt-minion.conf

echo "salt init: Starting minion ..."
service salt-minion start

echo "salt init: Done ..."
exit 0

  '''
  return template.format(keys.get('pub'), keys.get('priv'))


def _get_fqtopic(target, pillarenv, hints, agenda, topics):
  '''
  Return the fully qualified topic. This function takes the agenda, the available topics
  as the files existing in the assembly states tree and the current hints of the machine
  to figure out the next topic to run - and where, i.e. in a common or machine context.

  :param target:
    The node to look at - can only be a single node, no globbing

  :param pillarenv:
    Pillar environment as a string used as a prefix when looking for the topic in topics

  :param hints:
    The hints to use to get the last successful topic run on this node

  :param agenda:
    The list of topics that should be discussed with this node

  :param topics:
    The topics available in this environment, derived from the state files in the assembly

  :return:
    A two value return: the full topic name and the short name if the topic is available

  '''

  while True:

    # default assembly is common.baseline
    topic = hints.get('assembly', 'baseline')
    log.warning('Assembly: %s', topic)

    # When we are ready - we are ready :))
    if topic == 'ready':
      message = 'minion assemble: minion {} is in ready state - nothing to do'.format(target)
      log.warning(message)
      return None, topic

    # check if we have a viable agenda
    if topic in agenda:

      # look forward and put the next agenda topic into the opts
      idx = agenda.index(topic)
      log.debug('Current assembly index is %s', idx)

      # set the next assembly from the agenda - continue until ready
      hints['assembly'] = agenda[idx + 1]

    else:
      # the topic called for is not on the agenda
      message = 'minion_assemble: minion {} calls for assembly {} without a proper agenda!'.format(target, topic)
      log.error(message)
      log.error('Current agenda is %s', agenda)
      return False, topic

    # create the full topic path - its either from the pillarenv or the common pool - in either case its runnable
    # the more specific pillarenv will override the common topic, if both exist

    log.warning('Searching in pillarenv %s', pillarenv)
    if topic in topics.get(pillarenv, []):
      return pillarenv + '.' + topic, topic

    log.warning('Searching in common')
    if topic in topics.get('common', []):
      return 'common.' + topic, topic

    log.warning('No available assembly found for topic %s - try next ...', topic)


def show_opts(key=None):
  '''
  Show the contents of the options dict

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.show_opts
      salt-run alchemy.show_opts file_roots

  :param key:
    Optionally restrict the output to the given key

  :return:
    A dict with all options or only the one matching the given key
  '''

  if key is not None:
    return __opts__[key]

  return __opts__


def status(environment):
  '''
  Print a list of all the expected minions and their state - True (up) or false

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.status dev

  :param environment:
    Specify the pillar environment for which you want to get the list

  :return:
    A simple dict the minion id as key and the status as value
  '''

  _pillar = cpillar.fake_pillar(None, environment, '1nc', __opts__)
  domain = cpillar.dig(_pillar, 'defaults:network:manage:domain', '1nc')
  nodes = _pillar.get('hosts', {})
  nodes.update(_pillar.get('containers', {}))
  client = salt.client.LocalClient(__opts__['conf_file'])

  minions_status = {}
  for node, nodedata in nodes.iteritems():
    minions_status[nodedata.get('fqdn')] = False

  minions_found = client.cmd('*.' + domain, 'test.ping', timeout=1)
  for minion in sorted(minions_found):
    minions_status[minion] = True

  return minions_status


def up(environment):
  '''
  Print a list of all the expected minions and their state - True (up) or false

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.up dev

  :param environment:
    Specify the pillar environment for which you want to get the list

  :return:
    A simple dict with the minion id as key and the status as value
  '''

  minions_status = status(environment)
  minions_found = []
  for minion, isup in minions_status.iteritems():
    if isup is True:
      minions_found.append(minion)

  return minions_found


def down(environment, removekeys=False):
  '''
  Print a list of all the down or unresponsive salt minions
  Optionally remove keys of down minions

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.down
      salt-run alchemy.down removekeys=True

  :param environment:
    Specify the pillar environment for which you want to get the list

  :param removekeys:
    Delete the salt keys for any machine that is currently down

  :return:
    A simple dict
  '''

  minions_status = status(environment)
  minions_found = []
  for minion, isup in minions_status.iteritems():
    if isup is False:
      minions_found.append(minion)
      if removekeys:
        wheel = salt.wheel.Wheel(__opts__)
        wheel.call_func('key.delete', match=minion)

  return minions_found


def minion_accept(environment, group='hosts'):
  '''
  Accept available keys for all minions in a specific environment and of a specific type

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.minion_accept dev
      salt-run alchemy.minion_accept dev containers
      salt-run alchemy.minion_accept dev hosts

  :param environment:
    The pillar environment to act on

  :param group:
    The group to act on

  :return:
    A dict with the minions affected
  '''
  wheel = salt.wheel.Wheel(__opts__)
  nodes = cpillar.fake_pillar(None, environment, '1nc', __opts__).get(group, {})

  minions = []
  for node, nodedata in nodes.iteritems():
    minions.append(nodedata.get('fqdn'))

  return wheel.call_func('key.accept_dict', match={'minions_pre': minions})


def minion_assemble(target, caller='cmd', test=False, force=False):
  '''
  This function is called by the assemble reactor when a minion comes up. It needs to
  inspect the current hints of the minion and decide what to do next

  :param target:
    The minion id taken from the start event

  :param caller:
    Assume this function is called from the commandline and return state output. If you
    call it from somewhere else - like a reactor - set this value to something else to
    suppress any return values

  :param test:

  :param force:

  :return:
    Whatever result is returnable.
  '''

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)
  hints = client.cmd(target, 'grains.get', ['hints', {}]).get(target)

  if hints is None:
    message = 'minon_started: called by a minion that is unknown or not responding! {}'.format(target)
    log.critical(message)
    if caller == 'cmd':
      return {'Error': message}

    return

  log.info('minion_assemble: %s with hints=%s', target, hints)

  # compile the pillar for the target - we get it here with all roles reflected
  _pillar = cpillar.minion_pillar(target)

  if 'pillar' in hints:
    _pillar = salt.utils.dictupdate.merge_recurse(_pillar, hints.get('pillar'), {})

  # If we are not forced to run in any case check the pillar config if assemblies are enabled
  if not force and not cpillar.dig(_pillar, 'defaults:assemble', True):
    log.info('minion_assemble: Assembly reactor disabled by pillar configuration.')
    return True

  # get the list of available assemblies from the pillar (created from the files in base by external pillar)
  assembly = _pillar.get('assembly', {})

  # get a list assemblies requested to run
  # we want to use the local roles, but we try hints:agenda first
  roles = cpillar.dig(_pillar, 'local:roles', [])
  agenda = list(hints.get('agenda', roles))
  log.info('Agenda for target %s: %s', target, agenda)

  # retrieve the targets pillar environment from the fresh pillar
  pillarenv = _pillar.get('pillarenv', 'base')

  # add ready as last topic on the agenda - in the future we will stop there
  if 'ready' not in agenda:
    agenda.append('ready')

  # forward until we have a runnable topic - some might just be roles or not implemented, so we ignore them
  topic, short_topic = _get_fqtopic(target, pillarenv, hints, agenda, assembly)

  if topic is None:
    hint_update(target, hints, client)
    client.cmd(target, 'event.send', ['salt/minion/{}/topic/{}/success'.format(target, short_topic)])
    return True

  if topic is False:
    return False

  # if we run in test mode get out here and provide test data
  if test:
    data = {'module': topic, 'pillarenv': pillarenv, 'kwargs': hints}
    if __opts__.get('log_level', 'info') == 'info':
      data['roles'] = agenda
      data['assemblies'] = assembly

    return {target: data}

  # Run the assembly orchestration package
  log.warning('Running assemble on target %s for topic %s', target, topic)
  res = assemble(target, topic, **hints)

  # log.warning('Result of the call is %s', res)
  retcode = res['data'].get('retcode', 'X')

  # If the call was successful set the hints for the minion to the next topic and fire the proceed event
  if retcode == 0:
    log.debug('minion_assemble: Topic %s applied successfully.', topic)
    hint_update(target, hints, client)
    client.cmd(target, 'event.send', ['salt/minion/{}/topic/{}/success'.format(target, topic)])
    client.cmd(target, 'event.send', ['salt/minion/{}/assemble'.format(target)])
    if caller != 'cmd':
      return True
    else:
      return res

  client.cmd(target, 'event.send', ['salt/minion/{}/topic/{}/fail'.format(target, topic)])
  log.error('minion_assemble: Topic %s:%s caused an error (retcode is %s)', target, topic, retcode)
  return res

# FIXME: remove this test code
def test_runnable(assembly='baseline', pillarenv='dev'):
  '''
  Test runnable topics
  :param assembly:
  :param pillarenv:
  :return:
  '''
  target = 'ess-a1.cde.1nc'
  hints = {'assembly': assembly}
  agenda = ['baseline', 'cmdhist', 'third']
  topics = {'common': ['baseline', 'cmdhist'], 'dev': ['cmdhist', 'third'], 'cde': ['baseline', 'third']}

  topic = _get_fqtopic(target, pillarenv, hints, agenda, topics)

  if topic is None:
    return True

  if topic is False:
    return False

  print hints
  return "Nothing"


def hint_update(target, hints, client=None):
  '''
  Update the hints structure on a given target

  :param target:
    Pattern to identify the target for the hints to set

  :param hints:
    Dict containing the hints data

  :param client:
    Optionally an existing client object

  :return:
    Returns the hints data on success
  '''

  if client is None:
    client = salt.client.LocalClient(__opts__['conf_file'], __opts__)

  # if we have finished a hints based agenda remove it before storing it to the grains
  if 'agenda' in hints and hints['assembly'] == 'ready':
    del (hints['agenda'])

  client.cmd(target, 'grains.setvals', [{'hints': hints}])


def bootstrap_gen_accept(master_minion_id, keys=True, assembly='bootstrap', agenda='bootstrap'):
  '''
  Create the keys for the ess-a1 master minion

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.bootstrap_gen_accept ess-a1.cde.1nc

  :return:
    The data structure returned by the state call
  '''

  from os import path, makedirs

  res = {master_minion_id: {}}
  if keys:
    # generate and accept the keys for the local minion and create them
    # into the minion pki dir, too - so that the minion is already registered when
    # it comes up for the first time
    key_directory = '/etc/salt/pki/minion'

    if path.exists(key_directory + "/minion.pem"):
      return {master_minion_id: {'minion': 'keys already configured - doing nothing'}}

    wheel = _get_wheel()
    keys = wheel.call_func('key.gen_accept', args=[master_minion_id], kwargs={'force': True})

    if not path.exists(key_directory):
      makedirs(key_directory)

    outfile = open(key_directory + "/minion.pub", "w")
    outfile.write(keys.get('pub'))
    outfile.close()

    outfile = open(key_directory + "/minion.pem", "w")
    outfile.write(keys.get('priv'))
    outfile.close()

    # provide some output to return
    res[master_minion_id]['minion'] = 'Keys for minion {} created and accepted'.format(master_minion_id)

  # process the hints given with this call
  hints = {'assembly': assembly}

  if agenda is not None:
    if isinstance(agenda, basestring):
      hints['agenda'] = agenda.split(',')
    else:
      hints['agenda'] = agenda

  opts = salt.config.master_config('/etc/salt/master')
  opts['quiet'] = True
  opts['file_client'] = 'local'

  # save the grains
  minion = salt.minion.MasterMinion(opts)
  res = minion.functions['grains.setval']('hints', hints)

  return res

# FIXME: remove this test code
def check(path):
  '''
  For testing only
  :param path:
  :return:
  '''
  return _get_master_pillar(path, {})


def hosts_deploy(environment, nodes=None):
  '''
  Deploy a selected OS to all hosts of a named salt envrionment. This creates a public
  and a private key for the minion on the master, stores the public key in the masters
  accepted keys folder and sends both keys to the new host.

  As the private key is only stored on the minion itself, the master has no way to restore
  it if the host needs to be redeployed. Thus a new keypair will be created each time
  this function is run.

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.hosts_deploy dev
      salt-run alchemy.hosts_deploy dev node-01.dev.1nc

  :param environment:
    Name of the salt pillar environment

  :param nodes:
    Optional name of a known host in the working environment

  :return:
    The data structure returned by the client call
  '''

  import time

  wheel = _get_wheel()
  _pillar = cpillar.fake_pillar(None, environment, '1nc', __opts__)
  _nodes = _pillar.get('hosts', {})
  _zone = cpillar.dig(_pillar, 'defaults:maas:zone')

  opt = {'timeout': 1, 'expr_form': 'compound'}
  target = 'G@roles:maas and *.cde.1nc'
  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)

  if nodes is not None:
    nodes = nodes.split(',')

  res = {}
  for nid, node in _nodes.iteritems():

    fqdn = node.get('fqdn')
    if nodes is not None and fqdn not in nodes:
      log.debug("Skipping node %s", fqdn)
      continue

    log.info("Deploying node %s", nid)
    keys = wheel.call_func('key.gen_accept', args=[fqdn], kwargs={'force': True})
    userdata = _minion_key_wrapper(keys)

    actions = {}

    actions['acquired'] = client.cmd(target, 'maas.node_acquire', [fqdn], **opt)
    time.sleep(5)

    actions['deploy'] = client.cmd(target, 'maas.node_power_on', [fqdn, userdata], **opt)
    res[nid] = actions

  return res


def hosts_configure(target, scope=None, states=None, pillar=None, test=False, reboot=False):
  '''
  Do the basic configuration of all hosts met by target. Some parts of the target are already
  set within the calls - to make sure you do not apply certain states to machines that do
  not have the capabilities or need.

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.hosts_configure *.dev.1nc
      salt-run alchemy.hosts_configure node-01.dev.1nc scope=dev test=True

  :param target:
    Give a target glob for the configuration attempt

  :param scope:
    Optionally give a workspace - this will be transferred into the state tree environment parameter

  :param states:
    List of states to run (planned)

  :param pillar:
    Extra pillar to pass to the states

  :param test:
    Pass the test parameter to all the states executed

  :param bootstrap:
    Set bootstrap to true if you are bootstrapping the CDE environment and not all your
    services are already up and running

  :param reboot:
    Reboot the machines at the end of the configuration

  :return:
    The state dict

  '''
  __opts__['state_output'] = 'full'

  if states is None:
    states = ['core.roles', 'core']

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)

  if pillar is None:
    pillar = {}

  kwarg = {}

  if len(pillar) > 0:
    kwarg["pillar"] = pillar

  if test:
    kwarg["test"] = test

  id_, grains, _ = salt.utils.minions.get_minion_data('ess-a1.cde.1nc', __opts__)
  opt = {'expr_form': 'compound'}

  ret = {}

  ret['core.roles'] = client.cmd(target, 'state.sls', ['core.roles'], kwarg=kwarg, **opt)
  ret['core.resolver'] = client.cmd(target, 'state.sls', ['core.resolver'], kwarg=kwarg, **opt)

  ret['core'] = client.cmd(target, 'state.sls', ['core'], kwarg=kwarg, **opt)
  ret['distupgrade'] = client.cmd(target, 'state.sls', ['system.distupgrade'], kwarg=kwarg, **opt)
  ret['unlocked'] = client.cmd(target, 'state.sls', ['debug.unlocked'], kwarg=kwarg, **opt)
  ret['sshd'] = client.cmd(target, 'state.sls', ['sshd'], kwarg=kwarg, **opt)

  _t = target + ' and G@roles:host'
  # ret['ntp'] = client.cmd(_t, 'state.sls', ['ntp'], **opt)
  ret['core.grub'] = client.cmd(_t, 'state.sls', ['core.grub'], kwarg=kwarg, **opt)
  #  ret['network.netrules'] = client.cmd(_t, 'state.sls', ['network.netrules', scope], kwarg=kwarg, **opt)

  _t = target + ' and G@roles:host and not G@roles:containerhost'
  ret['network.host'] = client.cmd(_t, 'state.sls', ['network.host', scope], kwarg=kwarg, **opt)

  _t = target + ' and G@roles:containerhost'
  ret['containerhost'] = client.cmd(_t, 'state.sls', ['containerhost'], kwarg=kwarg, **opt)
  ret['network.containerhost'] = client.cmd(_t, 'state.sls', ['network.containerhost', scope], kwarg=kwarg, **opt)

  # Finally reboot after all steps
  if reboot:
    ret['reboot'] = client.cmd(target + ' and G@roles:host', 'cmd.run', ['reboot'], kwarg=kwarg, **opt)

  return ret


def hosts_release(environment, name=None):
  '''
  Release a single host or all hosts in a salt environment.

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.hosts_release dev
      salt-run alchemy.hosts_release dev node-01.dev.1nc

  :param environment:
    Name of the pillar environment to work on

  :param name:
    Optional name of a known host in the working environment

  :return:
    The data structure returned by the client call
  '''

  params = {}

  if name is not None:
    params = 'name={}'.format(name)
    glob = name
  else:
    _pillar = cpillar.fake_pillar(None, environment, '1nc', __opts__)
    glob = '*.{}'.format(cpillar.dig(_pillar, 'defaults:network:manage:domain'))
    zone = cpillar.dig(_pillar, 'defaults:maas:zone')
    params = 'name={}'.format(zone)

  # delete all matched keys - it is either name or all
  _get_wheel().call_func('key.delete', match=glob)

  opt = {'timeout': 1, 'expr_form': 'compound'}
  target = 'G@roles:maas and *.cde.1nc'

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)
  return client.cmd(target, 'maas.node_release', [params], **opt)


def hosts_destroy(environment, name=None):
  '''
  Destroy a single host or all hosts in a salt environment. This includes completely erasing
  their data - definition and historical - from the MaaS database.

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.hosts_destroy dev
      salt-run alchemy.hosts_destroy dev node-01.dev.1nc

  :param environment:
    Name of the pillar environment to work on

  :param name:
    Optional name of a known host in the working environment

  :return:
    The data structure returned by the client call
  '''

  params = {}
  res = {}

  if name is not None:
    params = 'name={}'.format(name)
    glob = name
  else:
    _pillar = cpillar.fake_pillar(None, environment, '1nc', __opts__)
    glob = '*.{}'.format(cpillar.dig(_pillar, 'defaults:network:manage:domain'))
    zone = cpillar.dig(_pillar, 'defaults:maas:zone')
    params = 'name={}'.format(zone)

  # delete all matched keys - it is either name or all
  _get_wheel().call_func('key.delete', match=glob)

  opt = {'timeout': 1, 'expr_form': 'compound'}
  target = 'G@roles:maas and *.cde.1nc'

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)
  res['release'] = client.cmd(target, 'maas.node_release', [params], **opt)
  res['delete'] = client.cmd(target, 'maas.node_delete', [params], **opt)
  return res


def container_deploy(target, name=None, role=None, bootstrap=False, test=False):
  '''
  Deploy all containers to the given target glob. Can be a single host or all containerhosts
  in a specific domain.

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.container_deploy *.dev.1nc
      salt-run alchemy.container_deploy node-01.dev.1nc bbox

  :param target:
    Give a target glob for the deployment attempt

  :param name:
    Select a single container to be deployed

  :param role:
    Select all containers of a specific role to be deployed

  :param test:
    If true, run states in dry mode, dont apply changes, just show what would be done.

  :return:
    The state dict
  '''
  __opts__['state_output'] = 'terse'

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)

  opt = {'expr_form': 'compound'}
  ret = {}

  kwarg = {'test': test}

  if name is not None:
    kwarg['name'] = name

  if role is not None:
    kwarg['role'] = role

  _t = target + ' and G@roles:containerhost'
  ret['container.deployed'] = client.cmd(_t, 'container.deployed', [], kwarg=kwarg, **opt)

  return ret


def container_destroy(target, name=None, role=None, test=False):
  '''
  Destroy all containers to the given target glob. Can be a single host or all containerhosts
  in a specific domain.

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.container_destroy *.dev.1nc
      salt-run alchemy.container_destroy node-01.dev.1nc bbox

  :param target:
    Give a target glob for the destroy attempt

  :param name:
    Select a single container to be destroyed

  :param role:
    Select all containers of a specific role to be destroyed

  :param test:
    If true, run states in dry mode, dont apply changes, just show what would be done.

  :return:
    The state dict
  '''
  __opts__['state_output'] = 'terse'

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)

  opt = {'expr_form': 'compound'}
  ret = {}

  kwarg = {'test': test}

  if name is not None:
    kwarg['name'] = name

  if role is not None:
    kwarg['role'] = role

  _t = target + ' and G@roles:containerhost'
  ret['container.destroyed'] = client.cmd(_t, 'container.destroyed', [], kwarg=kwarg, **opt)

  return ret


def container_enable(target, container):
  '''
  Create the keys for the minion and place them into target by calling the final state
  that will ensure the container is started

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.container_enable ess-a1.cde.1nc repo-a1

  :param target:
    The target salt minion on the containerhost that carries the minions container

  :param container:
    Name of the minion that should be accepted

  :return:
    The data structure returned by the state call
  '''

  __opts__['state_output'] = 'terse'
  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)
  wheel = _get_wheel()

  minion = client.cmd(target, 'pillar.get', ['containers:{}:fqdn'.format(container), {}]).get(target, None)

  if minion is None:
    log.error("Container enable failed: %s is not a valid container on target %s", container, target)
    return

  log.info("Enabling container %s: minion %s on target %s", container, minion, target)
  arguments = wheel.call_func('key.gen_accept', args=[minion], kwargs={'force': True})
  arguments['container'] = container

  kwarg = {'pillar': {'enable': arguments}, 'queue': True}
  action = client.cmd(target, 'state.sls', ['container.enable'], kwarg=kwarg)

  return action


def container_disable(target, container):
  '''
  Delete the keys for a container minion when the container is destroyed

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.container_disable ess-a1.cde.1nc repo-a1

  :param target:
    The target salt minion on the containerhost that carries the minions container

  :param container:
    Name of the minion that should be accepted

  :return:
    The data structure returned by the state call
  '''

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)
  minion = client.cmd(target, 'pillar.get', ['containers:{}:fqdn'.format(container), {}]).get(target, None)

  if minion is None:
    log.alert("Container disable failed: %s is not a valid container on target %s", container, target)
    return

  log.info("Disabling container %s: minion %s on target %s", container, minion, target)
  return _get_wheel().call_func('key.delete', match=minion)


def container_configure(target, scope=None, states=None, pillar=None, test=False):
  '''
  Do the basic configuration of all containers met by target. Some parts of the target are already
  set within the calls - to make sure you do not apply certain states to machines that do
  not have the capabilities or need.

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.containers_configure *.dev.1nc
      salt-run alchemy.containers_configure node-01.dev.1nc bbox

  :param target:
    Give a target glob for the configuration attempt

  :param scope:
    Optionally give a scope for the working environment

  :param states:
    List of states to run (planned)

  :param pillar:
    Extra pillar to pass to the states

  :param test:
    Pass the test parameter to all the states executed

  :return:
    The state dict

  '''
  __opts__['state_output'] = 'terse'

  client = salt.client.LocalClient(__opts__['conf_file'], __opts__)

  if pillar is None:
    pillar = {}

  kwarg = {}

  if len(pillar) > 0:
    kwarg["pillar"] = pillar

  if test:
    kwarg["test"] = test

  opt = {'expr_form': 'compound'}
  ret = {}

  ret['pillar.refresh'] = client.cmd(target, 'saltutil.refresh_pillar', [], **opt)

  # run roles on all minions ...
  ret['core.roles'] = client.cmd(target, 'state.sls', ['core.roles'], kwarg=kwarg, **opt)

  # and the next states only on containers
  _t = target + ' and G@roles:container'
  ret['core'] = client.cmd(_t, 'state.sls', ['core'], kwarg=kwarg, **opt)
  ret['distupgrade'] = client.cmd(_t, 'state.sls', ['system.distupgrade'], kwarg=kwarg, **opt)
  ret['unlocked'] = client.cmd(_t, 'state.sls', ['debug.unlocked'], kwarg=kwarg, **opt)
  ret['sshd'] = client.cmd(_t, 'state.sls', ['sshd'], kwarg=kwarg, **opt)

  return ret


def assemble(target, topic, saltenv='base', test=False, **kwargs):
  '''
  Assemble objects making up a complete infrastructure. It takes a set of orchestration states
  which are stored under the assemble directory in the base environment.

  This function should be idempotent, so it also should take care about changes.

  CLI Example:

  .. code-block:: bash

      salt-run alchemy.assemble *.dev.1nc cde.backend.essential
      salt-run alchemy.assemble node-01.dev.1nc cde.backend.essential bbox

  :param target:
    Give a target for the assemble run. This might be a salt glob for targeting or
    a defined pillar environment - like base, dev ...

  :param topic:
    Name of the assembly to run

  :param saltenv:
    The salt environment that contains the assembly that should be run

  :param test:
    Pass the test parameter to all the states executed

  :param kwargs:
    Named parameters for this function, which can be all hints and become the pillar for the state call

  :return:
    The state dict

  '''
  opts = salt.config.master_config('/etc/salt/master')
  opts['quiet'] = True
  opts['file_client'] = 'local'

  clean_kwargs = salt.utils.clean_kwargs(**kwargs)
  full_topic_path = 'assembly.' + topic

  # create call pillar and init it with stuff we might have gotten in the kwargs
  pillar = {'hints': clean_kwargs, 'target' :target}

  # if we are running under a scope, pass it through the pillar
  if 'scope' in opts:
    pillar['scope'] = opts['scope']

  # Scream if we messed it up
  if clean_kwargs is not None and not isinstance(clean_kwargs, dict):
    raise SaltInvocationError(
      'Pillar data must be formatted as a dictionary'
    )

  # run the assembly
  minion = salt.minion.MasterMinion(opts)
  running = minion.functions['state.sls'](
    full_topic_path,
    saltenv,
    test,
    None,
    pillar=pillar)

  ret = {'data': {minion.opts['id']: running}, 'outputter': 'highstate'}
  ret['data']['retcode'] = 0 if salt.utils.check_state_result(ret['data']) else 1

  return ret


def stint_begin(saltenv, stint_id):
  '''
  Begin a new stint - creates a file in /tmp announcing the stint.

  :param saltenv:
    The environment that this stint is meant for

  :param stint_id:
    The id of the stint to activate

  :return:
    True or False
  '''

  basepath = __opts__.get('stintfilepath', '/tmp')
  filename = '{}/{}.stint.sls'.format(basepath, saltenv)

  with open(filename, 'w') as stintfile:
    return stintfile.write(stint_id + '\n')

  return False


def stint_end(saltenv):
  '''
  End any currently active stint for the given environment

  :param saltenv:
    The environment that should be reset to normal

  :return:
    True or False

  '''
  import os

  basepath = __opts__.get('stintfilepath', '/tmp')
  filename = '{}/{}.stint.sls'.format(basepath, saltenv)

  if not os.path.isfile(filename):
    log.info('No stintfile found at %s - not deleting anything', filename)
    return True

  return True if os.unlink(filename) is None else False
