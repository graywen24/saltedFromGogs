'''
States for icinga2 management

'''
from __future__ import absolute_import

# Import python libs
import logging

__virtualname__ = 'icinga2'

# Init logger
log = logging.getLogger(__name__)


def cert_created(name, pkidir='/etc/icinga2/pki'):
    '''
    Ensures that the pki elements are valid on this machine, i.e
    - the certificate does exist
    - the cert is for this machine
    - the cert is signed by the cluster ca
    - the trusted cert and the ca cert are available

    :param name:
        The name/id of the state calling this

    :param pkidir:
        Path to the pki files

    :return:
        State info
    '''
    ret = {'changes': {},
           'comment': 'Certificate is complete and valid.',
           'name': name,
           'result': True}

    changes = []

    # require the ticket being available
    ticket = __salt__['grains.get']('icinga_ticket', False)
    if ticket is False:
        ret['comment'] = 'Cannot find the icinga2 ticket for this minion!'
        ret['result'] = False
        return ret

    # check if the files exist
    certs_exist = __salt__['icinga2.ssl_cert_exist'](pkidir)
    if not certs_exist:
        # if not, make new
        new = __salt__['icinga2.ssl_cert_new'](pkidir)
        if not new['success']:
            ret['comment'] = new['stdout']
            ret['result'] = False
            return ret

        changes.extend(new['stdout'])

        signed = __salt__['icinga2.ssl_cert_sign'](ticket, pkidir)
        if not signed['success']:
            ret['comment'] = signed['stdout']
            ret['result'] = False
            return ret

        changes.extend(signed['stdout'])
        ret['comment'] = 'Certificate has been updated.'
        ret['changes']['new'] = changes

    return ret

def cert_installed(name, pkidir='/etc/icinga2/pki'):
    '''
    Install a host certificate onto the current minion. Can be used
    to download certs from parents to enable proper cluster communication

    :param name:
        The name of the node to download the certificate from

    :param pkidir:
        Path to the pki files

    :return:
        State info
    '''
    ret = {'changes': {},
           'comment': 'Certificate is already installed.',
           'name': name,
           'result': True}

    changes = []

    # check if the files exist

    certs_exist = __salt__['file.file_exists']('{0}/{1}.crt'.format(pkidir, name))
    if not certs_exist:
        # if not, make new
        new = __salt__['icinga2.ssl_cert_get'](name, pkidir)
        if not new['success']:
            ret['comment'] = new['stdout']
            ret['result'] = False
            return ret

        changes.extend(new['stdout'])
        ret['comment'] = 'Certificate downloaded successfully.'
        ret['changes']['new'] = changes

    return ret


def cluster_update(name, isorigin=False, waitfor=60, repo='/var/lib/icinga2/api/repository'):
    '''
    Send a signal to the salt master that the icinga cluster needs an update

    :param name:
        The name of the node requesting the update
    :param isorigin:
        Is this event triggered on the origin of the activity or just not. The
        reason for this parameter is the fact, that updating the information on
        the parent cluster node for the node that has been updated takes a while.
        So if this event comes from the origin, we wont handle it on the spot,
        but wait a little until we run the action.

        This also keeps the opportunity to consolidate the actions on the parent
        node in the case that many machines got updated at the same time.
    :param waitfor:
        How long the receiving end should wait until running the action - currently
        set to 60 seconds.
    :param repo:
        Path to the files that contain the repo storage
    :return:
    '''
    ret = {'changes': {},
           'comment': '',
           'name': name,
           'result': True}

    status = __salt__['icinga2.cluster_update'](name, isorigin, waitfor, repo)
    ret['comment'] = status['comment']
    if not status['result']:
        ret['result'] = False
        return ret

    return ret


def ca_exists(name, pkidir='/etc/icinga2/pki'):
    ret = {'changes': {},
           'comment': 'CA has already been created.',
           'name': name,
           'result': True}

    changes = []

    status = __salt__['icinga2.ssl_cert_new_ca']()
    if not status['success']:
        ret['result'] = False
        ret['comment'] = status['stderr']
        return ret

    if status['stdout'] == 'EXISTS':
        return ret

    ret['comment'] = 'New CA has been created.'
    changes.extend(status['stdout'])

    status = __salt__['icinga2.ssl_cert_new_local'](name, pkidir)
    if not status['success']:
        ret['result'] = False
        ret['comment'] = status['stderr']
        return ret

    changes.extend(status['stdout'])

    status = __salt__['icinga2.ssl_cert_sign_local'](name, pkidir)
    if not status['success']:
        ret['result'] = False
        ret['comment'] = status['stderr']
        return ret

    changes.extend(['signed local csr and created certificate'])

    ret['changes']['new'] = changes

    return ret
