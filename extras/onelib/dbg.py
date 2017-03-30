
# import dbg
# dbg.start(**dbg.params)

from inspect import currentframe, getframeinfo
from os import path
from os import environ

DEBUG = bool(environ.get('DEBUG', False))
DEBUG = True

params = {'host': '192.168.192.21', 'port': 22100, 'stdoutToServer': True, 'stderrToServer': True, 'suspend': False }

def dbg_dummy(**kwargs):
  frameinfo = getframeinfo(currentframe().f_back)
  filename = path.splitext(path.basename(frameinfo.filename))[0]
  print 'DEBUGCALL({}): {}.{}:{}'.format(DEBUG, filename, frameinfo.function, frameinfo.lineno)
  return True

start = dbg_dummy
if DEBUG:
  try:
    import pydevd
  except ImportError:
    pass
  else:
    start = pydevd.settrace
