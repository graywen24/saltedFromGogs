'''
Support stints during deployment

This external pillar will load the key for a stint pillar from a file and merge the data of that key into
the general pillar. This allows to use specific configuration information during certain phases of
a deployment.

Example: A fully deployed environment will have 2 nameservers, but during deployment only one is available - until
the second is deployed. Lets call the stint during which only one ns is up *small*

1. Create a stintfile (pattern: /tmp/<pillarenv>.stint.sls:

  echo small > /tmp/cde.stint.sls

2. Create production pillar:
defaults:
  dns:
    servers:
      - 127.0.0.1
      - 127.0.0.2

3. Create stints pillar:
stints:
  small:
    defaults:
      dns:
        servers:
          - 127.0.0.1

4. Add the stints.sls to the pillar top file

So while the small stint is active, i.e. the file exists, the pillar will show 1 nameserver. Once the stint ends, i.e.
the file is removed, it will show 2 nameservers.


'''
from __future__ import absolute_import

import logging
import os

log = logging.getLogger(__name__)

# TODO: handle file errors
def _read_stint_id(filename):

  with open(filename, 'r') as stintfile:
    return stintfile.read().replace('\n', '')

  return {}


def ext_pillar(minion_id, pillar, *args, **kwargs):

  # set the working vars
  stintoptions = pillar.get('stints')
  basepath = __opts__.get('stintfilepath', '/tmp')
  saltenv = pillar.get('defaults', {}).get('saltenv', 'base')
  filename = '{}/{}.stint.sls'.format(basepath, saltenv)

  # remove stints from pillar if set
  if stintoptions is not None:
    del(pillar['stints'])

  # return if we do not have a stint file
  if not os.path.isfile(filename):
    log.info('No stintfile found at %s - not loading stint information', filename)
    return {}

  # merge stint pillar values into global pillar
  return stintoptions.get(_read_stint_id(filename), {})
