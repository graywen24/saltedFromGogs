# dhcpd subnet and group definitions for the {{ data.subnet.group }} environment
#
# {{ pillar.defaults.hint }}
#

# define subnet
subnet {{ data.subnet.address }} netmask {{ data.subnet.netmask }} {

  # this is the interface that we receive requests on. As we are in a container
  # it should always be eth0
  # but: dont mention it, dhcpd sucks on shared networks. Thats why we dont activate - dhcpd
  # fails to start if enabled, works fine if not told about it ... grrrr
  # interface "eth0";

}

# define the group
# the group contains the options for this subnet and all host/ip bindings by mac address
group {{ data.subnet.group }} {
{% for key, value in data.options.iteritems() %}
{%- if value|length() > 0 %}
  option {{ key }} {{ value }};
{%- endif %}
{%- endfor %}
{% for host in data.hosts %}
  host {{ host.fqdn }} { hardware ethernet {{ host.mac }} ; fixed-address {{ host.ip }}; }
{%- endfor %}

}

