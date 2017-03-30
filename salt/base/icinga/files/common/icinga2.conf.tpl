/**
 * Icinga 2 configuration file
 *
 * {{ pillar.defaults.hint }}
 */

/**
 * The constants.conf defines global constants.
 */
include "constants.conf"
include "local.d/constants.conf"

/**
 * The zones.conf defines zones for a cluster setup.
 */
include "zones.conf"

/**
 * The Icinga Template Library (ITL) provides a number of useful templates
 * and command definitions.
 */
include <itl>
include <plugins>
// include <plugins-contrib>

/**
 * The enabled features
 */
include "features-enabled/*.conf"

/**
 * Global templates
 */
include_recursive "global.d"

{% set mole = salt.icinga2.node_mole() -%}
{% if not mole == 'hosts' -%}
/**
 * On a collecting host, make sure we have the host dummies included
 */
include_recursive "hosts.d"
{%- endif %}

/**
 * Local valid configurations
 */
include_recursive "local.d"

