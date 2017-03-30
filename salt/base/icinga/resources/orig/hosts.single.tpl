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

