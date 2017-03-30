/**
 * The example notification apply rules.
 *
 * Only applied if host/service objects have
 * the custom attribute `notification` defined
 * and containing `mail` as key.
 *
 * Check `hosts.conf` for an example.
 */

apply Notification "mail-icingaadmin" to Host {
  import "mail-host-notification"

  user_groups = host.vars.notification.mail.groups
  users = host.vars.notification.mail.users

  assign where host.vars.notification.mail
}

apply Notification "mail-icingaadmin" to Service {
  import "mail-service-notification"

  user_groups = host.vars.notification.mail.groups
  users = host.vars.notification.mail.users

  assign where host.vars.notification.mail
}
