#!/usr/bin/python

# Copyright 2012 Canonical Ltd. All rights reserved.
# Author: Haw Loeung <haw.loeung@canonical.com>

import json
import os
import pprint
import subprocess
import sys

juju_warning_headers = """#
#    "             "
#  mmm   m   m   mmm   m   m
#    #   #   #     #   #   #
#    #   #   #     #   #   #
#    #   "mm"#     #   "mm"#
#    #             #
#  ""            ""
# This file is managed by Juju. Do not make local changes.
#"""


def hook_install(config):
    pprint.pprint(globals())
    pprint.pprint(locals())
    return 0


def hook_config_changed(config):
    pprint.pprint(globals())
    pprint.pprint(locals())
    return 0


def log(debug, msg):
    if debug:
        print msg


def run(command, *args, **kwargs):
    try:
        output = subprocess.check_output(command, *args, **kwargs)
        return output
    except Exception, e:
        print str(e)
        raise


#------------------------------------------------------------------------------
# config_get:  Returns a dictionary containing all of the config information
#              Optional parameter: scope
#              scope: limits the scope of the returned configuration to the
#                     desired config item.
#------------------------------------------------------------------------------
def config_get(scope=None):
    config_cmd_line = ["config-get", "--format=json"]
    if scope is not None:
        config_cmd_line.append(scope)
    return json.loads(run(config_cmd_line))


def relation_ids_get(relation_name=None):
    try:
        relation_cmd_line = ["relation-ids", "--format=json"]
        if relation_name is not None:
            relation_cmd_line.append(relation_name)
            return json.loads(run(relation_cmd_line))
    except Exception:
        return None


#------------------------------------------------------------------------------
# relation_get:  Returns a dictionary containing the relation information
#                Optional parameters: scope, relation_id
#                scope:        limits the scope of the returned data to the
#                              desired item.
#                unit_name:    limits the data ( and optionally the scope )
#                              to the specified unit
#                relation_id:  specify relation id for out of context usage.
#------------------------------------------------------------------------------
def relation_get(scope=None, unit_name=None, relation_id=None):
    try:
        relation_cmd_line = ["relation-get", "--format=json"]
        if relation_id is not None:
            relation_cmd_line.extend(('-r', relation_id))
        if scope is not None:
            relation_cmd_line.append(scope)
        if unit_name is not None:
            relation_cmd_line.append('-')
            relation_cmd_line.append(unit_name)
        relation_data = json.loads(run(relation_cmd_line))
    except Exception:
        relation_data = None
    finally:
        return(relation_data)


def main():
    hook_name = os.path.basename(sys.argv[0])
    config = config_get()
    config["juju_warning_headers"] = juju_warning_headers

    log(config["debug"], "Hook: %s" % hook_name)

    if hook_name == "install":
        sys.exit(hook_install(config))
    elif hook_name == "config-changed":
        sys.exit(hook_config_changed(config))
    elif hook_name == "upgrade-charm":
        ret = hook_install(config)
        if ret:
            sys.exit(ret)
        sys.exit(hook_config_changed(config))
    else:
        print "Unsupported hook: %s" % hook_name
        sys.exit(0)


if __name__ == "__main__":
    main()
