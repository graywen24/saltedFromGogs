{% if 'container' in grains.roles %}

no_kernel_log:
  file.replace:
  - name: /etc/rsyslog.conf
  - pattern: "^[^#]ModLoad imklog"
  - repl: "# $ModLoad imklog"

no_kernel_log_options:
  file.replace:
  - name: /etc/rsyslog.conf
  - pattern: "^[^#]KLogPermitNonKernelFacility on"
  - repl: "# $KLogPermitNonKernelFacility on"


rsyslog_watch:
  service.running:
  - name: rsyslog
  - sig: rsyslogd
  - watch:
    - file: no_kernel_log
    - file: no_kernel_log_options

{% endif %}
