
# install packages
icinga2_packages:
  pkg.latest:
  - pkgs:
    - icinga2
    - nagios-plugins
    - bc
{% if 'host' in grains.roles %}
    - sysstat
{% endif -%}

{% if not 'icinga_ca' in grains.roles %}
# tell the master to get a ticket from the icinga ha master and
# store it in our grains
icinga2_ssl_prepare:
  event.send:
  - name: icinga2/pki/gricket

{% endif -%}
