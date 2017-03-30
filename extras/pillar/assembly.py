import logging
import os

log = logging.getLogger(__name__)


def ext_pillar(minion_id, pillar, *args, **kwargs):
  '''
  Create a data structure that informs about available assembly items.

  :return:
    Dict of lists, where the dict keys are top level directory names in assembly
  '''

  rootfolder = '/srv/salt/base'
  assemblyfolder = 'assembly'
  walkbase = '{}/{}'.format(rootfolder, assemblyfolder)

  data = {}

  # os.walk treats dirs breadth-first, but files depth-first (go figure)
  for root, dirs, files in os.walk(walkbase):
    # print the directories below the root

    path = root.partition(walkbase.rstrip('/') + '/')[-1].split('/')
    env = path[0]

    path = '.'.join(path[1:])
    states = []

    for assembly in files:

      all_parts = []
      statename = assembly.partition('.sls')[0]

      # if path has a value, append it to the empty list
      if len(path) > 0:
        all_parts.append(path)

      # if name is init use the directory name instead
      if statename == 'init':
        statename = ""

      # if the statename has a value append it to the parts
      if len(statename) > 0:
        all_parts.append(statename)

      # if we have any parts join them and append them to the states
      if len(all_parts) > 0:
        state = '.'.join(all_parts)
        states.append(state)

    # if we have any states push them to the data structure
    if len(states) > 0:
      if data.has_key(env):
        data[env].extend(states)
      else:
        data[env] = states

  return {'assembly': data}
