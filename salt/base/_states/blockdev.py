# -*- coding: utf-8 -*-
'''
Management of Block Devices

A state module to manage blockdevices

.. code-block:: yaml


    /dev/sda:
      blockdev.tuned:
        - read-only: True

    master-data:
      blockdev.tuned:
        - name: /dev/vg/master-data
        - read-only: True
        - read-ahead: 1024


.. versionadded:: 2014.7.0
'''
from __future__ import absolute_import

# Import python libs
import os
import os.path
import time
import logging

# Import salt libs
import salt.utils
from salt.ext.six.moves import range
from salt.exceptions import CommandExecutionError

__virtualname__ = 'blockdev'

# Init logger
log = logging.getLogger(__name__)


def __virtual__():
    '''
    Only load this module if the blockdev execution module is available
    '''
    if 'blockdev.tune' in __salt__:
        return __virtualname__
    return (False, ('Cannot load the {0} state module: '
                    'blockdev execution module not found'.format(__virtualname__)))


def _checkblk(name):
    '''
    Check if the blk exists and return its fstype if ok
    '''

    blk = __salt__['cmd.run']('lsblk -o fstype {0}'.format(name)).splitlines()
    return '' if len(blk) == 1 else blk[1]

def _getdevice(blockdev=""):
    '''
    Given a blockdevice name - something like sda3 or /dev/sda3 - it will return
    the device this thing is on: sda or /dev/sda in this case. Taken from the list
    of actually available devices on the machine, i.e. will work for other name conventions too
    '''
    devices = __salt__['partition.get_block_device']()

    for device in devices:
        if device in blockdev:
            starts_at = blockdev.find(device)
            ends_at = starts_at + len(device)
            return blockdev[0:ends_at]

    return ""

def _getpartnum(blockdev=""):
    '''
    Given a blockdevice name - something like sda3 or /dev/sda3 - it will return
    the the number of the device, i.e. partition: 3
    '''
    devices = __salt__['partition.get_block_device']()

    for device in devices:
        if device in blockdev:
            starts_at = blockdev.find(device)
            ends_at = starts_at + len(device)
            if len(blockdev) > ends_at:
                return blockdev[ends_at]

    return ""


def _getfsmapping(fstype):
    '''
    This maps an actual fstype to a type selector for parted, which is used
    to define the partition type to be created.

    For example, parted knows ext2, but not ext4.
    '''

    mappings = { 'ext4' : 'ext2', 'ext3' : 'ext2'}
    if mappings.has_key(fstype):
        return mappings[fstype]

    return fstype


def _getblockdevinfo(blockdev="", unit='s'):
    '''
    Get the info for a blockdevice and fix stuff in the output
    '''

    info_out = {}
    device = _getdevice(blockdev)
    partid = _getpartnum(blockdev)

    if len(partid) == 0:
        raise CommandExecutionError('No partition id given - need something like sdx1, not sdx.')

    info_in = __salt__['partition.list'](device, unit)

    info_out['drive'] = info_in['info']
    info_out['partition'] = info_in['partitions'][partid]

    info_out['partition']['partlabel'] = info_out['partition']['file system']
    info_out['partition']['file system'] = info_out['partition']['type']
    info_out['partition'].pop('type', None)

    return info_out

def _format(device, fs_type='ext4', inode_size=None, lazy_itable_init=None):
    '''
    Format a filesystem onto a block device

    .. versionadded:: 2015.8.2

    device
        The block device in which to create the new filesystem

    fs_type
        The type of filesystem to create

    inode_size
        Size of the inodes

        This option is only enabled for ext and xfs filesystems

    lazy_itable_init
        If enabled and the uninit_bg feature is enabled, the inode table will
        not be fully initialized by mke2fs.  This speeds up filesystem
        initialization noticeably, but it requires the kernel to finish
        initializing the filesystem  in  the  background  when  the filesystem
        is first mounted.  If the option value is omitted, it defaults to 1 to
        enable lazy inode table zeroing.

        This option is only enabled for ext filesystems

    CLI Example:

    .. code-block:: bash

        salt '*' blockdev.format /dev/sdX1
    '''
    cmd = ['mkfs', '-t', str(fs_type)]
    if inode_size is not None:
        if fs_type[:3] == 'ext':
            cmd.extend(['-i', str(inode_size)])
        elif fs_type == 'xfs':
            cmd.extend(['-i', 'size={0}'.format(inode_size)])
    if lazy_itable_init is not None:
        if fs_type[:3] == 'ext':
            cmd.extend(['-E', 'lazy_itable_init={0}'.format(lazy_itable_init)])
    cmd.append(str(device))

    mkfs_success = __salt__['cmd.retcode'](cmd, ignore_retcode=True) == 0
    sync_success = __salt__['cmd.retcode']('sync', ignore_retcode=True) == 0

    return all([mkfs_success, sync_success])

def _fstype(device):
    '''
    Return the filesystem name of a block device

    .. versionadded:: 2015.8.2

    device
        The name of the block device

    CLI Example:

    .. code-block:: bash

        salt '*' blockdev.fstype /dev/sdX1
    '''
    if salt.utils.which('lsblk'):
        lsblk_out = __salt__['cmd.run']('lsblk -o fstype {0}'.format(device)).splitlines()
        if len(lsblk_out) > 1:
            fs_type = lsblk_out[1].strip()
            if fs_type:
                return fs_type

    if salt.utils.which('df'):
        # the fstype was not set on the block device, so inspect the filesystem
        # itself for its type
        df_out = __salt__['cmd.run']('df -T {0}'.format(device)).splitlines()
        if len(df_out) > 1:
            fs_type = df_out[1]
            if fs_type:
                return fs_type

    return ''

def blockdevinfo(blockdev="", name=None):
    ret = {'changes': _getblockdevinfo(blockdev),
           'comment': '',
           'name': name,
           'result': True}

    return ret

def tuned(name, **kwargs):
    '''
    Manage options of block device

    name
        The name of the block device

    opts:
      - read-ahead
          Read-ahead buffer size

      - filesystem-read-ahead
          Filesystem Read-ahead buffer size

      - read-only
          Set Read-Only

      - read-write
          Set Read-Write
    '''

    ret = {'changes': {},
           'comment': '',
           'name': name,
           'result': True}

    kwarg_map = {'read-ahead': 'getra',
                 'filesystem-read-ahead': 'getfra',
                 'read-only': 'getro',
                 'read-write': 'getro'}

    if not __salt__['file.is_blkdev']:
        ret['comment'] = ('Changes to {0} cannot be applied. '
                          'Not a block device. ').format(name)
    elif __opts__['test']:
        ret['comment'] = 'Changes to {0} will be applied '.format(name)
        ret['result'] = None
        return ret
    else:
        current = __salt__['blockdev.dump'](name)
        changes = __salt__['blockdev.tune'](name, **kwargs)
        changeset = {}
        for key in kwargs:
            if key in kwarg_map:
                switch = kwarg_map[key]
                if current[switch] != changes[switch]:
                    if isinstance(kwargs[key], bool):
                        old = (current[switch] == '1')
                        new = (changes[switch] == '1')
                    else:
                        old = current[switch]
                        new = changes[switch]
                    if key == 'read-write':
                        old = not old
                        new = not new
                    changeset[key] = 'Changed from {0} to {1}'.format(old, new)
        if changes:
            if changeset:
                ret['comment'] = ('Block device {0} '
                                  'successfully modified ').format(name)
                ret['changes'] = changeset
            else:
                ret['comment'] = 'Block device {0} already in correct state'.format(name)
        else:
            ret['comment'] = 'Failed to modify block device {0}'.format(name)
            ret['result'] = False
    return ret


def formatted(name, fs_type='ext4', **kwargs):
    '''
    Manage filesystems of partitions.

    name
        The name of the block device

    fs_type
        The filesystem it should be formatted as
    '''
    ret = {'changes': {},
           'comment': '{0} already formatted with {1}'.format(name, fs_type),
           'name': name,
           'result': False}

    if not os.path.exists(name):
        ret['comment'] = '{0} does not exist'.format(name)
        return ret

    current_fs = _checkblk(name)

    if current_fs == fs_type:
        ret['result'] = True
        return ret
    elif not salt.utils.which('mkfs.{0}'.format(fs_type)):
        ret['comment'] = 'Invalid fs_type: {0}'.format(fs_type)
        ret['result'] = False
        return ret
    elif __opts__['test']:
        ret['comment'] = 'Changes to {0} will be applied '.format(name)
        ret['result'] = None
        return ret

    # __salt__['blockdev.format'](name, fs_type, **kwargs)
    formatted = _format(name, fs_type, **kwargs)
    # current_fs = __salt__['blockdev.fstype'](name)
    current_fs = _fstype(name)

    # Repeat lsblk check up to 10 times with 3s sleeping between each
    # to avoid lsblk failing although mkfs has succeeded
    # see https://github.com/saltstack/salt/issues/25775
    for i in range(10):

        log.info('Check blk fstype attempt %s of 10', str(i+1))
        current_fs = _checkblk(name)

        if current_fs == fs_type:
            ret['comment'] = ('{0} has been formatted '
                              'with {1}').format(name, fs_type)
            ret['changes'] = {'new': fs_type, 'old': current_fs}
            ret['result'] = True
            return ret

        if current_fs == '':
            log.info('Waiting 3s before next check')
            time.sleep(3)
        else:
            break

    ret['comment'] = 'Failed to format {0}'.format(name)
    ret['result'] = False
    return ret


def getdevice(name, **kwargs):

    device = _getdevice(name)

    ret = {'changes': {},
           'comment': 'Hoha - device is {0}'.format(device),
           'name': name,
           'result': True}

    return ret

def created(name, start, end, partlabel=None, fs_type='ext2', table='gpt', **kwargs):
    '''
    Manage partition on blockdevice.

    name
        The name of the block device

    start,end
        The size of the partition to be created

    table:
        The type of the partition table we want to create

    fs_type
        The filesystem it should be formatted as

    partlabel
        The name for the filesystem when using gpt
    '''
    ret = {'changes': {},
           'comment': 'A blockdevice {0} already exist'.format(name),
           'name': name,
           'result': False}

    # get the device from the path given
    device = _getdevice(name)
    if len(device) == 0:
        ret['comment'] = 'Cannot determine parent device for {0}'.format(name)
        return ret

    # figure out if the device has any partitions and complain if supersafe
    if kwargs.has_key('supersafe') and kwargs['supersafe'] == True:
        hasparts = len(__salt__['cmd.run']('lsblk -o type {0} | grep part'.format(device)).splitlines()) == 0
        if hasparts:
            ret['comment'] = 'Found partitions on device {0} - giving up! You will need to remove them first'.format(device)
            return ret

    if __salt__['partition.exists'](name):
        blockdevinfo = _getblockdevinfo(name)
        if blockdevinfo['drive']['partition table'] != table:
            ret['comment'] = 'The partition table for the drive is not {0}!'.format(table)
            return ret

        if blockdevinfo['partition']['partlabel'] == partlabel:
            ret['comment'] = ('A partition with the same name and partlabel exists.\n- start: {0}\n- end  : {1}\n- size : {2}' \
                              .format(blockdevinfo['partition']['start'], blockdevinfo['partition']['end'], blockdevinfo['partition']['size']))
            ret['result'] = True
            return ret

        return ret

    if __opts__['test']:
        ret['comment'] = 'Changes to {0} will be applied '.format(name)
        ret['result'] = None
        return ret

    # got so far - create a disklabel first, use gpt as default because we use big disks :)
    hastable = __salt__['partition.mklabel'](device, table)
    if len(hastable) != 0:
        ret['comment'] = 'Error creating a new partition table on device {0}: {1}'.format(device, hastable)
        return ret

    ret['changes']['1:table'] = 'Created partition table as {0}'.format(table)

    mkpart = __salt__['partition.mkpart'](device, 'primary', _getfsmapping(fs_type), start, end)
    if len(mkpart) > 0:
        ret['comment'] = 'Something did go wrong: {0}'.format(mkpart)
        return ret

    ret['changes']['2:part'] = 'Created partition for blockdevice {0}'.format(name)

    if partlabel:
        setname = __salt__['partition.name'](device, _getpartnum(name), partlabel)
        if len(setname) > 0:
            ret['comment'] = 'Problem naming the partition: {0}: {1}'.format(partlabel, setname)
            return ret
        ret['changes']['3:label'] = 'Named the device {0} as {1}'.format(name, partlabel)

    ret['comment'] = 'Successfully created new blockdevice'
    ret['result'] = True
    return ret
