/*
 * Service apply rules.
 *
 * The CheckCommand objects `ping4`, `ping6`, etc
 * are provided by the plugin check command templates.
 * Check the documentation for details.
 *
 * Tip: Use `icinga2 object list --type Service` to
 * list all service objects after running
 * configuration validation (`icinga2 daemon -C`).
 */

/*
 * This is an example host based on your
 * local host's FQDN. Specify the NodeName
 * constant in `constants.conf` or use your
 * own description, e.g. "db-host-1".
 */

/*
 * These are generic `ping4` and `ping6`
 * checks applied to all hosts having the
 * `address` resp. `address6` attribute
 * defined.
 */
apply Service "ping4" {
  import "generic-service"

  check_command = "ping4"

  assign where host.address
}

apply Service "ping6" {
  import "generic-service"

  check_command = "ping6"

  assign where host.address6
}

/*
 * Apply the `ssh` service to all hosts
 * with the `address` attribute defined and
 * the custom attribute `os` set to `Linux`.
 */
apply Service "ssh" {
  import "generic-service"

  check_command = "ssh"

  assign where (host.address || host.address6) && host.vars.os == "Linux"
}



apply Service for (http_vhost => config in host.vars.http_vhosts) {
  import "generic-service"

  check_command = "http"

  vars += config
}

apply Service for (disk => config in host.vars.disks) {
  import "generic-service"

  check_command = "disk"

  vars += config
}

apply Service "icinga" {
  import "generic-service"

  check_command = "icinga"

  assign where host.name == NodeName
}

apply Service "load" {
  import "generic-service"

  check_command = "load"

  /* Used by the ScheduledDowntime apply rule in `downtimes.conf`. */
  vars.backup_downtime = "02:00-03:00"

  assign where host.name == NodeName
}

apply Service "procs" {
  import "generic-service"

  check_command = "procs"

  assign where host.name == NodeName
}

apply Service "swap" {
  import "generic-service"

  check_command = "swap"

  assign where host.name == NodeName
}

apply Service "users" {
  import "generic-service"

  check_command = "users"

  assign where host.name == NodeName
}



