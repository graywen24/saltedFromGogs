'''
module to get containers controlled

'''

# Import python libs
from __future__ import absolute_import
import logging
from salt.exceptions import CommandExecutionError

import salt.utils.dictupdate as udict

# Set up logging
log = logging.getLogger(__name__)

# Import salt libs
#import salt.utils
#from salt.exceptions import CommandExecutionError, SaltInvocationError


def _getcontainerlist(name=None, node=None, role=None, active_only=False, container_pillar=None):

    if container_pillar is None:
        container_pillar = __salt__['pillar.get']('containers', {})

    containerlist={}

    for key, container in container_pillar.iteritems():

        if active_only and container.get('active', True) is False:
            log.info('Skipping inactive container %s', key)
            continue

        config = {"target": container['target'], "id": container['fqdn']}

        if not any((name, role)):
            if node is None or container['target'] == node:
                containerlist[key] = config
        elif name and not role:
            if name == key and (node is None or container['target'] == node):
                containerlist[key] = config
        elif not name and role:
            if role in container['roles'] and (node is None or container['target'] == node):
                containerlist[key] = config
        else:
            if name == key and (node is None or container['target'] == node) and role in container['roles']:
                containerlist[key] = config

    return containerlist


def _containeraction(state, prefix, name=None, role=None, test=False, active_only=False):

    node = __salt__['pillar.get']('local:fqdn')
    log.debug('Calling containerlist for node %s', node)

    containerlist = _getcontainerlist(name, node, role, active_only)
    if len(containerlist) == 0:
        return 'No containers for target \'{1}\': Filter role={0};name={2}'.format(role, node, name)

    ret = {}
    for key, container in containerlist.iteritems():
        if not test:
            pl = {'container': key}
            ret[key] = __salt__['state.sls'](mods=state, pillar=pl)
        else:
            ret[key] = "{0} target {1}".format(prefix, node)

    return ret


# Container existence/non-existence
def deployed(name=None, role=None, test=True):
    ret = _containeraction('container.deployed', "Installing to", name, role, test, True)
    return ret


# Container existence/non-existence
def destroyed(name=None, role=None, test=True):
    ret = _containeraction('container.destroyed', "Destroying on", name, role, test)
    return ret


def purged(name=None, role=None, test=True):
    ret = _containeraction('container.purged', "Purging on", name, role, test)
    return ret


def list(name=None, role=None, active_only=True):

    callerrole = __opts__.get('__role', None)
    if callerrole is None or callerrole == 'master':
        raise CommandExecutionError('Func list not usable in master context! Use masterlist instead!')

    return _getcontainerlist(name, None, role, active_only)


def masterlist(environment, name=None, target=None, role=None, active_only=True):
    import cpillar

    callerrole = __opts__.get('__role', None)
    if callerrole is None or callerrole == 'minion':
        log.error("Masterlist called with callerrole %s!", callerrole)
        raise CommandExecutionError('Func masterlist not usable in minion context! Use list instead!')

    log.warning("Masterlist called with callerrole %s!", callerrole)

    _pillar = cpillar.fake_pillar(None, environment, "1nc", __opts__)
    container_pillar = cpillar.dig(_pillar, 'containers')

    return _getcontainerlist(name, target, role, active_only, container_pillar)

