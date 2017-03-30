/*
 * {{ pillar.defaults.hint }}
 *
 * Active checks are checks that the central machine does
 * on a remote host. This template defines which checks are
 * run this way. It is meant to be simple. So ping and available
 * services (http, smtp, ...) are to be configured
 *
 * Host definitions with object attributes
 * used for apply rules for Service, Notification,
 * Dependency and ScheduledDowntime objects.
 *
 * Tip: Use `icinga2 object list --type Host` to
 * list all host objects after running
 * configuration validation (`icinga2 daemon -C`).
 */

/*
 * This is an example host based on your
 * local host's FQDN. Specify the NodeName
 * constant in `constants.conf` or use your
 * own description, e.g. "db-host-1".
 */

object Host "{{ host }}" {

  /* Import the default host template defined in `templates.conf`. */
  import "generic-host"

  /* Specify the address attributes for checks e.g. `ssh` or `http`. */
  address = "{{ ip4.split('/')[0] }}"
  address6 = ""

  /* Set custom attribute `os` for hostgroup assignment in `groups.conf`. */
  vars.os = "Linux"

  /* Define http vhost attributes for service apply rules in `services.conf`. */
  // vars.http_vhosts["http"] = {
  //   http_uri = "/"
  // }
  /* Uncomment if you've sucessfully installed Icinga Web 2. */
  //vars.http_vhosts["Icinga Web 2"] = {
  //  http_uri = "/icingaweb2"
  //}

{% if 'disk' in grains.roles -%}
  /* Define disks and attributes for service apply rules in `services.conf`. */
  vars.disks["disk"] = {
    /* No parameters. */
  }
  vars.disks["disk /"] = {
    disk_partitions = "/"
  }
{% endif -%}

  /* Define notification mail attributes for notification apply rules in `notifications.conf`. */
  vars.notification["mail"] = {
    /* The UserGroup `icingaadmins` is defined in `users.conf`. */
    groups = [ "icingaadmins" ]
  }
}
