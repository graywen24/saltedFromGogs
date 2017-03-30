from __future__ import absolute_import
from salt.ext.six import string_types

import logging
log = logging.getLogger(__name__)


def skey_present(name,
            user=None,
            keyserver=None,
            text=None,
            gnupghome=None,
            trust=None,
            **kwargs):
  '''
  Ensure GPG public key is present in keychain

  name
      The unique name or keyid for the GPG public key.

  keys
      The keyId or keyIds to add to the GPG keychain.

  user
      Add GPG keys to the user's keychain

  keyserver
      The keyserver to retrieve the keys from.

  text
      If a keyserver is not available, a pem formatted key may be passed

  gnupghome
      Override GNUPG Home directory

  trust
      Trust level for the key in the keychain,
      ignored by default.  Valid trust levels:
      expired, unknown, not_trusted, marginally,
      fully, ultimately


  '''

  ret = {'name': name,
         'result': True,
         'changes': {},
         'comment': []}

  _key = __salt__['gpg.get_secret_key'](keyid=name)

  if not _key:

    if text is not None:
      result = __salt__['gpg.import_key'](text)

      if 'res' in result and not result['res']:
        ret['result'] = result['res']
        ret['comment'] = result.get('message', "")
      else:
        ret['comment'] = 'Added {0} to GPG keychain'.format(name)
        ret['changes'] = result

    else:
      result = __salt__['gpg.receive_keys'](keyserver,
                                            name,
                                            user,
                                            gnupghome,
                                            )
      if 'result' in result and not result['result']:
        ret['result'] = result['result']
        ret['comment'].append(result['comment'])
      else:
        ret['comment'].append('Adding {0} to GPG keychain'.format(name))

  else:
    ret['comment'] = 'Key {0} already in GPG keychain'.format(name)

  return ret
