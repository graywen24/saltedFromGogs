from __future__ import absolute_import

import os
import yaml
import logging
import salt.utils

log = logging.getLogger(__name__)


def data(filelist, buffersize):
  '''
  This reads the common database for node configurations from the given filelist.

  The resulting data structure must contain the members hosts and containers

  :param filelist:
    List of yaml formatted files to import

  :return:
    Data structure read from the nodebase
  '''

  nodebase_data = {}

  for file in filelist:

    if not os.path.isfile(file):
      log.error('file_tree: %s: not a regular file', file)
      continue

    nodebase_contents = ''
    try:
      with salt.utils.fopen(file, 'rb') as fhr:
        buf = fhr.read(buffersize)
        while buf:
          nodebase_contents += buf
          buf = fhr.read(buffersize)
    except (IOError, OSError) as exc:
      log.error('file_tree: Error reading %s: %s',
                file,
                exc.strerror)

    nodebase_parsed = yaml.safe_load(nodebase_contents)
    if not isinstance(nodebase_parsed, dict):
      log.info('Ignoring pillar stack template "{0}": Can\'t parse '
               'as a valid yaml dictionary'.format(file))
      continue

    nodebase_data.update(nodebase_parsed)

  return nodebase_data
