'''
Collection of alchemy specific states

Small stuff that did not directly qualify for its own state module

.. versionadded:: 2015.5.5
'''
from __future__ import absolute_import

# Import python libs
import logging

__virtualname__ = 'alchemy'

# Init logger
log = logging.getLogger(__name__)


def key_exists(name, file, source, keyring='/etc/apt/trusted.gpg',
               saltenv=None):
    '''
    Check if a specific apt key exists and install it if not

    :param name:
        Key id of the key in question - can be long or short format

    :param file:
        Basename of the key file for informational purposes.

    :param source:
        Source uri of the key file in the salt repository that contains the
        key in ascii text form.

    :param keyring:
        Path to the keyring where the key should be looked up (
        default: /etc/apt/trusted.gpg)

    :param saltenv:
        Specify the saltenv - default is the current

    :return:
        State object
    '''
    ret = {'changes': {},
           'comment': 'Something went wrong, key not installed!',
           'name': name,
           'result': False}

    cmd = 'gpg --quiet --no-default-keyring --keyring {0} --list-keys {1}'.format(
        keyring, name)

    key_success = __salt__['cmd.retcode'](cmd, ignore_retcode=True) == 0
    if key_success:
        ret['comment'] = 'Key {0}/{1} already installed.'.format(name, file)
        ret['result'] = True
        return ret

    if __opts__['test']:
        ret['comment'] = 'Key {0}/{1} would be installed.'.format(name, file)
        ret['result'] = None
        return ret

    searchenv = __env__
    if saltenv != None:
        searchenv = saltenv

    sfn = __salt__['cp.cache_file'](source, searchenv)
    if sfn == False:
        ret[
            'comment'] = 'Unable to download file \'{0}\' from saltenv \'{1}\''.format(
            source, searchenv)
        return ret

    cmd = 'gpg --quiet --no-default-keyring --keyring {0} --import {1}'.format(
        keyring, sfn)

    import_success = __salt__['cmd.retcode'](cmd, ignore_retcode=True) == 0
    if import_success:
        ret['comment'] = 'Key imported from {0}'.format(source)
        ret['changes'] = {"old": "none", "new": "Key {0} imported".format(name)}
        ret['result'] = True
        return ret

    return ret


def key_absent(name, file, keyring='/etc/apt/trusted.gpg'):
    '''
    Check if a specific apt key exists and remove it if present

    :param name:
        Key id of the key in question - can be long or short format

    :param file:
        Basename of the key file for informational purposes.

    :param keyring:
        Path to the keyring where the key should be looked up (
        default: /etc/apt/trusted.gpg)

    :return:
        State object
    '''
    ret = {'changes': {},
           'comment': 'Something went wrong, key not removed!',
           'name': name,
           'result': False}

    cmd = 'gpg --quiet --no-default-keyring --keyring {0} --list-keys {1}'.format(
        keyring, name)

    key_failed = __salt__['cmd.retcode'](cmd, ignore_retcode=True) != 0
    if key_failed:
        ret['comment'] = 'Key {0}/{1} is not installed.'.format(name, file)
        ret['result'] = True
        return ret

    if __opts__['test']:
        ret['comment'] = 'Key {0}/{1} would be removed.'.format(name, file)
        ret['result'] = None
        return ret

    cmd = 'gpg --batch --yes --quiet --no-default-keyring --keyring {0} --delete-key {1}'.format(
        keyring, name)

    delete_success = __salt__['cmd.retcode'](cmd, ignore_retcode=True) == 0
    if delete_success:
        ret['comment'] = 'Key deleted '
        ret['changes'] = {"old": "{0}/{1}".format(name, file), "new": "none"}
        ret['result'] = True
        return ret

    return ret


def lxc_available(name):
    '''
    Check if a container of the given name is available

    :param name:
        Name of the container to look for

    :return:
        State object
    '''

    ret = {'name': name,
           'result': True,
           'comment': 'Container \'{0}\' already exists'.format(name),
           'changes': {}}

    if __salt__['lxc.exists'](name):
        return ret

    ret['comment'] = 'Container \'{0}\' needs to be installed'.format(name),
    ret['changes']['state'] = "missing"
    return ret


def upgrade(name, dist_upgrade=False):
    '''
    Upgrade the packages of the target system, optionally run dist-upgrade

    :param name:
        Name of the state instance

    :param dist_upgrade:
        If dist-upgrade should be used

    :return:
        State object
    '''
    name = 'upgrade'
    if dist_upgrade:
        name = 'dist-upgrade'

    ret = {'name': name,
           'result': True,
           'comment': 'Running \'apt-get {0}\' for system {1}'.format(name,
                                                                      __salt__[
                                                                          'grains.get'](
                                                                          'fqdn',
                                                                          'UNKOWN???')),
           'changes': __salt__['pkg.upgrade'](dist_upgrade)}

    return ret
