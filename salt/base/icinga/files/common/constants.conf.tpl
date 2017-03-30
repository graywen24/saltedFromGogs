/**
 * {{ pillar.defaults.hint }}
 *
 * This file defines global constants which can be used in
 * the other configuration files.
 */

/* The directory which contains the plugins from the Monitoring Plugins project. */
const PluginDir = "/usr/lib/nagios/plugins"

/* The directory which contains the Manubulon plugins.
 * Check the documentation, chapter "SNMP Manubulon Plugin Check Commands", for details.
 */
const ManubulonPluginDir = "/usr/lib/nagios/plugins"

/* The directory which you use to store additional plugins which ITL provides user contributed command definitions for.
 * Check the documentation, chapter "Plugins Contribution", for details.
 */
const PluginContribDir = "/usr/lib/nagios/plugins"

/* Our local instance name. By default this is the server's hostname as returned by `hostname --fqdn`.
 * This should be the common name from the API certificate.
 */
const NodeName = "{{ grains.fqdn }}"

/* The ip of the local instance.
*/
const NodeIP = "{{ salt.alchemy.node_ip() }}"

/* Our local zone name. */
const ZoneName = "{{ salt.icinga2.node_zone() }}"

{% if 'icinga_ca' in grains.roles -%}
/* Secret key for remote node tickets */
const TicketSalt = "{{ pillar.icinga.salt }}"
{% endif %}

const LinuxOsList = [ "Ubuntu", "RedHat" ]
const WindowsOsList = [ "Windows" ]
