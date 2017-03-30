'''

This runner makes Salt's
execution modules available
on the salt master.

Execution modules can be
called with ``salt-run``:

.. code-block:: bash

    salt-run modules.execute test.ping
    # call functions with arguments and keyword arguments
    salt-run modules.execute test.arg 1 2 3 key=value a=1

Execution modules are also available to salt runners:

.. code-block:: python

    __salt__['modules.execute'](fun=fun, args=args, kwargs=kwargs)

'''
# import python libs
from __future__ import absolute_import
from __future__ import print_function
import logging

# import salt libs
import salt.loader
import salt.config
import salt.utils

log = logging.getLogger(__name__)  # pylint: disable=invalid-name


def execute(function, *args, **kwargs):
  '''
  Execute ``fun`` with the given ``args`` and ``kwargs``.
  Parameter ``fun`` should be the string :ref:`name <all-salt_modules>`
  of the execution module to call.

  Note that execution modules will be *loaded every time*
  this function is called.

  CLI example:

  .. code-block:: bash

      salt-run modules.execute test.ping
      # call functions with arguments and keyword arguments
      salt-run modules.execute test.arg 1 2 3 a=1
  '''

  # load a master minion
  kws = salt.utils.clean_kwargs(**kwargs)
  if kws.has_key('args'):
    args = kws.get('args', [])
    del(kws['args'])

  __opts__['file_client'] = 'local'
  minion = salt.minion.MasterMinion(__opts__)

  running = minion.functions[function](*args, **kws)

  ret = {'data': {minion.opts['id']: running}}
  ret['data']['retcode'] = 0 if salt.utils.check_state_result(ret['data']) else 1

  return ret
