#!/usr/bin/python

__version__ = '0.1'

import MySQLdb as mdb
import sys
import argparse

class ArgumentParserError(Exception): pass

class ThrowingArgumentParser(argparse.ArgumentParser):
  def error(self, message):
    raise ArgumentParserError(message)

parser = ThrowingArgumentParser()
parser.description = "Check for outdated Icinga2 check results."
parser.add_argument("-H", "--Hostname", action="store", dest="Hostname", help="MySQL Server (ip or hostname)", required=True)
parser.add_argument("-d", "--database", action="store", dest="database", default="icinga", help="Icinga2 MySQL databasename [default: %(default)s]")
parser.add_argument("-u", "--user", action="store", dest="user", help="MySQL Login username", required=True)
parser.add_argument("-p", "--password", action="store", dest="password", help="MySQL Login password", required=True)
parser.add_argument("-f", "--buffer", action="store", dest="buffer", help="Buffer in seconds to add to the freshness threshold [default: %(default)s]", default="60")
try:
  arguments = parser.parse_args()
except ArgumentParserError, exc:
  print "UNKNOWN: " + exc.message
  sys.exit(3)

query = """
SELECT
    *, NOW() AS timenow
FROM
    (SELECT
        object_id,
            name1 as host,
            name2 as service,
            current_state,
            'service' as rtype,
            ISE.freshness_threshold,
            ISS.last_check,
            ISS.last_check + INTERVAL (ISE.freshness_threshold + 300) SECOND AS max_crit_freshness_time
    FROM
        icinga_objects IOB
    INNER JOIN icinga_servicestatus ISS ON IOB.object_id = ISS.service_object_id
        AND IOB.instance_id = ISS.instance_id
    INNER JOIN icinga_services ISE ON ISS.service_object_id = ISE.service_object_id
    WHERE
        IOB.is_active = 1 AND ISS.current_state = 0 AND ISS.problem_has_been_acknowledged = 0
	UNION
    SELECT
        object_id,
            name1 as host,
            name2 as service,
            current_state,
            'host' as rtype,
            ISE.freshness_threshold,
            ISS.last_check,
            ISS.last_check + INTERVAL (ISE.freshness_threshold + 300) SECOND AS max_crit_freshness_time
    FROM
        icinga_objects IOB
    INNER JOIN icinga_hoststatus ISS ON IOB.object_id = ISS.host_object_id
        AND IOB.instance_id = ISS.instance_id
    INNER JOIN icinga_hosts ISE ON ISS.host_object_id = ISE.host_object_id
    WHERE
        IOB.is_active = 1 AND ISS.current_state = 0 AND ISS.problem_has_been_acknowledged = 0) AS OLDIES
HAVING timenow > OLDIES.max_crit_freshness_time;
        """.format(arguments.buffer)

def run():
  con = mdb.connect(arguments.Hostname, arguments.user, arguments.password, arguments.database)
  cur = con.cursor(mdb.cursors.DictCursor)

  try:
    cur.execute(query)
    results = cur.fetchall()

    hosts = filter(lambda x: "host" in x["rtype"], results)
    services = filter(lambda x: "service" in x["rtype"], results)

    unfresh_count = len(results)
    longoutput = ""

    hosts_map = [str(x["rtype"]) + ": " + str(x["host"]) for x in hosts]
    hostString = "\n".join([str(x) for x in hosts_map])
    if hostString:
      longoutput = "\n" + hostString
    services_map = [str(x["rtype"]) + ": " + str(x["host"]) + "!" + str(x["service"]) for x in services]
    servicesString = "\n".join([str(x) for x in services_map])
    longoutput += "\n" + servicesString

    if unfresh_count > 0:
      print "Checks outdated: " + str((unfresh_count)) + " | " + longoutput
      sys.exit(2)
    else:
      print "Checks OK: No outdated results."
      sys.exit(0)
  except mdb.Error, e:
    print "Unknown: %d: %s" % (e.args[0], e.args[1])
    sys.exit(3)

  finally:

    if con:
      con.close()

if __name__ == '__main__':
  run()
