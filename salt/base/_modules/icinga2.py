'''
Expose alchemy helper functions

'''

# Import python libs
from __future__ import absolute_import
from ast import literal_eval
import glob
import logging

# Set up logging
log = logging.getLogger(__name__)


def _run(cmd):
  '''
  Run the command given and return a generic information dict
  :param cmd:
      The command to run
  :return:
      A dict returning some of the information that we gathered when
      the command was executed
  '''
  res = {}
  run = __salt__['cmd.run_all'](cmd)

  res['success'] = run['retcode'] == 0
  res['stdout'] = run['stdout'].splitlines()
  res['stderr'] = run['stderr'].splitlines()
  res['comment'] = cmd[0:55] + ' ...'

  return res


def _matchitems(haystack, filter):
  '''
  Returns true if haystack begins with one of the strings in the filter
  :param haystack:
      String to be searched in
  :param filter:
      Comma separated string of needles
  :return:
      True or false
  '''

  log.warning('Testing for haystack %s and filter %s', haystack, filter)
  if filter == '*':
    return True

  needles = filter.split(',')
  for needle in needles:
    if haystack.startswith(needle):
      return True

  log.warning('Result is False')
  return False


def _findFileByContentString(path, contentstring, contents=False):
  '''
  Find the first file from a set of files that contains the given contentstring

  :param path:
      Path and path pattern so select the files, understands globs

  :param contentstring:
      Searchstring to find in a file

  :param contents:
      If True, return the contents of the file found, not the filename only

  :return:
      String, either filename or filecontents
  '''

  for fn in glob.iglob(path):
    shakes = open(fn, "r")
    log.debug('Search in file %s', fn)
    for line in shakes:
      if contentstring in line:
        log.info('Found matching file %s', fn)
        shakes.close()
        if not contents:
          return fn
        else:
          with open(fn) as f:
            return f.read()

    shakes.close()

  return ''


def node_mole():
  '''
  Get the monitoring role (mole) for the current minion

  :return:
      the mole as string, i.e. masters, satellites, hosts
  '''
  nodename = __salt__['grains.get']('nodename')
  node = __salt__['pillar.get']('hosts:' + nodename, __salt__['pillar.get'](
    'containers:' + nodename, {}))
  mole = node.get('mole',
                  __salt__['pillar.get']('monitor:basemole', 'hosts'))
  return mole


def node_zone():
  zone = mole_zone()
  if zone is None:
    return __salt__['grains.get']('id')

  return zone


def mole_list():
  '''
  Get the possible monitoring roles (moles) in the current minions saltenv

  :return:
      the moles as a dict where the value points to the parent mole
  '''

  result = {}
  for mole, config in __salt__['pillar.get']('monitor:moles', {}).iteritems():
    parent = config.get('parent', None)
    if isinstance(parent, basestring) and parent.lower() == 'none':
      parent = None
    result[mole] = parent

  return result


def mole_parent(mole=None):
  '''
  Get the parent for a mole in the callers saltenv

  :param mole:
      The mole you want to get the parent for

  :return:
      The parent for that mole
  '''

  if mole is None:
    mole = node_mole()

  return mole_list().get(mole, None)


def zone_endpoints(mole=None):
  '''
  Get the endpoints for a zone identified by its mole

  :param mole:
      The mole you want to get the endpoints for

  :return:
      The list of endpoints for that mole
  '''

  default = []

  if mole is None:
    mole = node_mole()

  if mole == __salt__['pillar.get']('monitor:basemole', 'hosts'):
    default = [__salt__['grains.get']('id')]

  return __salt__['pillar.get']('monitor:moles:{0}:endpoints'.format(mole), default)


def mole_nodes(saltenv, mole=None, filter='*'):
  '''
  Returns a dict of nodes, optionally filtered by monitoring roles (moles)

  :param saltenv:
      The environment to take the nodes from

  :param filter:
      Mole string to return the nodes for

  :return:
      dict containing the result grouped by mole or dict with all nodes
      in a mole group
  '''
  res = {}
  zonenodes = __salt__['pillar.get']('nodes:' + saltenv, {})

  for nodeid, node in zonenodes.iteritems():

    if node['active'] and _matchitems(nodeid, filter):
      nodemole = node['mole']
      if not res.has_key(nodemole):
        res[nodemole] = dict()
      res[nodemole][nodeid] = node

  if mole is not None:
    if res.has_key(mole):
      return res[mole]
    else:
      return {}

  return res


def mole_features():
  '''
  Return a list of features that should be enabled or disabled for the calling minion.
  These are taken from the grains and merged with a mole based list.

  :return:
      A dict with 2 keys, namely enabled and disabled listing the respective features
  '''
  available = ['api', 'checker', 'command', 'compatlog', 'debuglog',
               'gelf', 'graphite', 'icingastatus', 'ido-mysql', 'livestatus',
               'mainlog', 'notification', 'opentsdb', 'perfdata',
               'statusdata', 'syslog']

  common_features = __salt__['pillar.get']('monitor:features:common',
                                           [])
  mole_features = __salt__['pillar.get'](
    'monitor:features:' + node_mole(), [])

  res = {}
  res['enabled'] = list(set(common_features).union(mole_features))
  res['disabled'] = list(set(available).difference(res['enabled']))
  return res


def ssl_cert_new_ca():
  '''
  Create a new CA for the icinga2 instances

  :return:
      command result state
  '''

  cakey = __salt__['file.file_exists']('/var/lib/icinga2/ca/ca.key')
  cacrt = __salt__['file.file_exists']('/var/lib/icinga2/ca/ca.crt')

  result = {}
  if not cakey and not cacrt:
    cmd = '/usr/sbin/icinga2 pki new-ca'
    result = _run(cmd)
  else:
    result['success'] = True
    result['stdout'] = 'EXISTS'
    result['stderr'] = ''
    result['comment'] = ''

  return result


def ssl_cert_ticket(endpoint):
  '''
  Retrieve a ticket for a specific endpoint so certs can be exchanged

  :param endpoint:
      Endpoint we want to have the ticket for

  :return:
      The ticket as a string
  '''

  nodename = __salt__['grains.get']('id')
  cmd = '/usr/sbin/icinga2 pki ticket --cn {0} '.format(endpoint)
  res = _run(cmd)

  if not res['success']:
    log.error('Aquire ticket for endpoint %s on %s failed: %s', endpoint, nodename, res['stderr'])
    return ""

  return res['stdout'][0]


def ssl_cert_exist(pkidir='/etc/icinga2/pki'):
  '''
  Check if the icinga2 certificates exist in the given path

  :param pkidir:
      Path to the certificate files

  :return:
      True or false
  '''
  nodename = __salt__['grains.get']('id')
  key = __salt__['file.file_exists']('{0}/{1}.key'.format(pkidir, nodename))
  crt = __salt__['file.file_exists']('{0}/{1}.crt'.format(pkidir, nodename))
  ca = __salt__['file.file_exists']('{0}/ca.crt'.format(pkidir))
  return key and crt and ca


def ssl_cert_new(pkidir='/etc/icinga2/pki'):
  '''
  Create new certificates for the current minion

  :param pkidir:
      Path to the certificate files

  :return:
      dunno
  '''

  nodename = __salt__['grains.get']('id')
  cmd = '/usr/sbin/icinga2 pki new-cert --cn {1} --key {0}/{1}.key --cert {0}/{1}.crt'.format(
    pkidir, nodename)

  return _run(cmd)


def ssl_cert_get(fqdn, pkidir='/etc/icinga2/pki'):
  '''
  Download a certificate from another node to establish communication

  :param fqdn:
      Name (fqdn) of the node to download the certificate from

  :param pkidir:
      Path to the certificate files

  :return:
      dunno
  '''

  cmd = 'icinga2 pki save-cert --host {1} --trustedcert {0}/{1}.crt'.format(
    pkidir, fqdn)
  return _run(cmd)


def ssl_cert_sign(ticket, pkidir='/etc/icinga2/pki'):
  '''
  Run Icinga2 command to get your local certs signed by the master instance

  :param pkidir:
      Path to the certificate files

  :return:
      dunno
  '''

  nodename = __salt__['grains.get']('id')
  # TODO: dynamic master
  master = __salt__['pillar.get']('monitor:ca_master')

  res = {}
  tpl = '/usr/sbin/icinga2 pki save-cert --host {0} --key {2}/{3}.key --cert {2}/{3}.crt --trustedcert {2}/{0}.crt'
  cmd = tpl.format(master, ticket, pkidir, nodename)
  cmdres = _run(cmd)

  if not cmdres['success']:
    return cmdres
  else:
    res = cmdres

  tpl = '/usr/sbin/icinga2 pki request --host {0} --ticket {1} --key {2}/{3}.key --cert {2}/{3}.crt --trustedcert {2}/{0}.crt --ca {2}/ca.crt'
  cmd = tpl.format(master, ticket, pkidir, nodename)
  cmdres = _run(cmd)

  if not cmdres['success']:
    return cmdres
  else:
    res['stdout'].extend(cmdres['stdout'])

  return res


def ssl_cert_new_local(nodename, pkidir='/etc/icinga2/pki'):
  '''
  Create a local certificate request - to be signed

  :param nodename:
      The CN of the node to create the certificate for

  :param pkidir:
      Path to certificate files

  :return:
      command result state
  '''
  cmd = '/usr/sbin/icinga2 pki new-cert --cn {1} --key {0}/{1}.key --csr /tmp/{1}.csr'.format(
    pkidir, nodename)

  return _run(cmd)


def ssl_cert_sign_local(nodename, pkidir='/etc/icinga2/pki'):
  '''
  Sign a locally generated certificate

  :param nodename:
      The CN of the node to create the certificate for

  :param pkidir:
      Path to certificate files

  :return:
      command result state
  '''
  cmd = '/usr/sbin/icinga2 pki sign-csr --csr /tmp/{1}.csr --cert {0}/{1}.crt'.format(
    pkidir, nodename)

  return _run(cmd)


def pytoicingalist(thelist):
  return '[ ' + ','.join('"{0}"'.format(e) for e in thelist) + ' ]'


def pytoicingadict(thedict):
  parts = []
  for e, f in thedict.iteritems():
    if type(f) is int:
      parts.append('{0} = {1}'.format(e, f))
    else:
      parts.append('{0} = "{1}"'.format(e, f))

  return '{ ' + ', '.join(parts) + ' }'


def node_update():
  '''
  Run icinga command node update-config

  :return:
      True or False
  '''

  cmd = '/usr/sbin/icinga2 node update-config'
  cmdres = _run(cmd)

  res = {}
  if not cmdres['success']:
    return cmdres
  else:
    res = cmdres

  cmd = 'service icinga2 reload'
  cmdres = _run(cmd)

  if not cmdres['success']:
    return cmdres
  else:
    res['stdout'].extend(cmdres['stdout'])

  return res


def node_checks():
  """
  Create a list of checks required on this minion, created from its os information merged into
  the list of roles and then compared to the monitor:checks pillar keys. The result is a simple
  list of strings where each should point to a config file in checks-available.

  :return:
      List of configuration pointers
  """

  # get the os type to look for in the checks list
  osdogma = 'windows'
  for lookupname, osnames in __salt__['pillar.get']('monitor:oslist', {}).iteritems():
    if __salt__['grains.get']('os') in osnames:
      osdogma = lookupname
      break

  includes = []
  config = {}
  _checks = __salt__['pillar.get']('monitor:checks:' + osdogma, [])

  for role in __salt__['grains.get']('roles'):
    _checks.extend(__salt__['pillar.get']('monitor:checks:' + role, _checks))
    log.debug("Handle role %s ... %s", role, _checks)

  for check in _checks:
    log.debug("check: %s", check)
    if type(check) is dict:
      _check = check.keys()[0]
      config[_check] = check[_check]
      check = _check.split('.')[0]
    if check not in includes:
      includes.append(check)

  log.debug('Checks for this machine: %s', includes)
  return {"includes": includes, "config": config}


def node_services():
  '''
  List services configured for icinga on this node. Information is parsed
  from icinga2 object list output

  :return:
      JSON object containing services and extra data
  '''

  node = __salt__['grains.get']('id')
  cmd = ['icinga2', 'object', 'list', '--type=service',
         '--name={0}*'.format(node)]
  cmdres = _run(' '.join(cmd))

  services = {}
  object = {}

  inobject = False

  for line in iter(cmdres['stdout']):

    if not inobject:
      inobject = line.startswith('Object')
      log.debug("Starting object: " + line)
    else:
      log.debug('Handle line: %s', line)
      tline = line.strip(' \n')
      if tline.startswith('*') and tline.find('=') > 0:
        vline = tline.strip('* ')
        (key, val) = vline.split(' = ', 2)
        if val in ['true', 'false']:
          val = val.capitalize()
        if val == 'null':
          val = '[ ]'
        if key in ['check_command', 'display_name', 'type', 'groups', 'templates', 'name']:
          object[key] = literal_eval(val)
          log.debug("Adding variable {0} = {1}".format(key, val))
        if key == 'zone':
          inobject = False
          services[object['name']] = object
          log.debug("Closing object " + object['name'])
          object = {}

  return services


def mole_zone(mole=None):
  """
  Return the zone name for a specific mole with in the minions
  salt environment. If the mole is hosts the minion id is returned.

  :param mole:
      The mole to translate - default is the minions mole

  :return:
      The zone name
  """

  if mole is None:
    mole = node_mole()

  default = __salt__['grains.get']('id')

  return __salt__['pillar.get']('monitor:moles:{0}:zone'.format(mole), default)


def zone_mole(zone=None):
  """
  Return the mole for the given zone. If the zone is the same as the minion id the
  minons mole is returned. If the zone is not retrievable the basemole is returned.
  If the basemole is not set the default is hosts.

  :param zone:
      The name of the zone to be translated into a mole - default is the minions zone

  :return:
      The mole for the given zone.
  """

  if zone is None:
    zone = node_zone()

  node = __salt__['grains.get']('id')
  if zone == node:
    return node_mole()

  moles = __salt__['pillar.get']('monitor:moles', {})
  for mole, moledata in moles.iteritems():
    if moledata.get('zone', '') == zone:
      return mole

  return __salt__['pillar.get']('monitor:basemole', 'hosts')


def zone_parent(zone=None):
  """
  Find the parent zone for the given zone.

  :param zone:
      The zone to find the parent for

  :return:
      Parent zone name
  """

  if zone is None:
    zone = node_zone()

  mole = zone_mole(zone)
  parent = mole_parent(mole)

  if parent is None:
    return None

  return mole_zone(parent)


def zone_walk(node=None, all=False):
  """
  Collect all siblings and parent nodes for source and possible nodes in the same
  zone then the source. These are the nodes that need to be informed
  about monitoring configuration updates of the source node.

  :param start:
      Node to start the walk with

  :return:
      List of node id's
  """
  if node is None:
    node = __salt__['grains.get']('id')

  mole = node_mole()
  endpoints = []

  while True:
    endpoints += zone_endpoints(mole)
    mole = mole_parent(mole)
    if mole is None:
      break

  return [value for value in endpoints if all or value != node]


def zone_parents(zone=None):
  """
  Collect all endpoints in the parent zone ...

  :param zone:
      Zone to collect the endpoints for

  :return:
      List of endpoints found
  """

  parent = zone_parent(zone)
  mole = zone_mole(parent)
  return zone_endpoints(mole)


def cluster_update_request():
  '''
  This is the entry point to signal upstream servers that an icinga
  node has been updated and that the cluster should review its
  configuration for this node.

  You fire this event from the node that had the update. It will also be
  fired by the handler if more upstream nodes are found and the event needs
  to bubble up.

  :return:
      the ret object data

  '''

  source = __salt__['grains.get']('id')
  mole = node_mole()
  log.info('Issue cluster_update_request from %s', source)

  data = {'action': 'configure',
          'services': node_services(),
          'ip4': __salt__['alchemy.node_ip'](),
          'roles': pytoicingalist(__salt__['grains.get']('roles')),
          'os': __salt__['grains.get']('os'),
          'mole': mole,
          'endpoint': source,
          'zone': mole_zone(mole),
          'zone_endpoints': zone_endpoints(),
          'parent_zone': zone_parent(),
          'publish_endpoints': zone_walk()
          }

  ret = {'comment': 'Message send successfully',
         'result': True}

  res = __salt__['event.send']('icinga2/cluster/update_request', data)
  if not res:
    ret['comment'] = \
      'Weird - something prevent the event from being send ...'
    ret['result'] = False
    return ret
  return ret


def cluster_removal_request():
  '''
  This is the entry point to signal upstream servers that an icinga
  node has been updated and that the cluster should review its
  configuration for this node.

  You fire this event from the node that had the update. It will also be
  fired by the handler if more upstream nodes are found and the event needs
  to bubble up.

  :return:
      the ret object data

  '''

  source = __salt__['grains.get']('id')
  mole = node_mole()

  log.info('Issue cluster_removal_request from %s', source)

  data = {'action': 'deconfigure',
          'endpoint': source,
          'zone': mole_zone(mole),
          'publish_endpoints': zone_walk()}

  ret = {'comment': 'Message send successfully',
         'result': True}

  res = __salt__['event.send']('icinga2/cluster/update_request', data)
  if not res:
    ret['comment'] = \
      'Weird - something prevent the event from being send ...'
    ret['result'] = False
    return ret
  return ret


def maasdb_info():
  '''
  On a machine that has the maas role read the connection information for the database
  and provide it to icinga for monitoring purposes

  :return:
    Database configuration information for a maas instance

  '''

  import os.path
  if not os.path.isfile('/etc/maas/maas_local_settings.py'):
    return {'valid': False}

  import sys
  sys.path.insert(0, '/etc/maas')
  m = __import__('maas_local_settings', globals(), locals(), [])
  del sys.path[0]

  dbinfo = {
    'valid': True,
    'hostname': m.DATABASES['default']['HOST'],
    'database': m.DATABASES['default']['NAME'],
    'username': m.DATABASES['default']['USER'],
    'password': m.DATABASES['default']['PASSWORD']
  }

  return dbinfo


def icingadb_info(raw=False):

  mysqlconfig = __salt__['pillar.get']('icinga:mysql', {})

  if len(mysqlconfig) == 0:
    return {'Problem': 'There is not available database configuration for this operation!'}

  connection_args = {
    'connection_host': mysqlconfig.get('dbhost', 'localhost'),
    'connection_db': mysqlconfig.get('dbname', 'icinga2'),
    'connection_user': mysqlconfig.get('dbuser', ''),
    'connection_pass': mysqlconfig.get('dbpass', ''),
    'connection_charset': mysqlconfig.get('charset', 'utf8'),
  }

  query = 'Select * from icinga_dbversion;'

  data = __salt__['mysql.query'](connection_args.get('connection_db'), query, **connection_args)

  if raw:
    return data

  record = data.get('results', [])[0]

  return {'id': record[0],'version': record[2], 'created': record[3], 'changed': record[4]}

