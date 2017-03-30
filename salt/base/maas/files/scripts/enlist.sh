#!/usr/bin/env bash

if [ -z $MAAS_APIKEY ]; then
        MAAS_APIKEY=$1
fi

node_id=""
cluster=cde
force_nodes=False

node_create() {
  name=$1
  mac=$2
  arch=$3
  sub=$4

  node_exists=$(maas $cluster nodes list mac_address=$mac | awk -F"\"" '/system_id/ { print $4 }')

  if [ "$node_exists" != "" ]; then
    if [ "$force_nodes" == "True" ]; then
      echo "Deleting existing node $name ($node_exists)"
      maas $cluster node delete $node_exists > /dev/null
    else
      echo "Skipping existing node $name ($node_exists)"
      return 1
    fi
  fi

  node_id=$(maas $cluster nodes new architecture=$arch mac_addresses=$mac hostname=$name nodegroup= subarchitecture=$sub | awk -F"\"" '/system_id/ { print $4 }')
  maas $cluster node abort-operation $node_id > /dev/null
  echo "Created node $name ($node_id)"
  return 0

}

node_power() {
  powertype=$1
  powerip=$2
  powerpass=$3
  powerid=$4

  pparams=""

  case $powertype in
   'ipmi')
      icmd="ipmitool -I lanplus -H $powerip -U root -P 2m@nyw0rk"
      powerpass=$(pwgen -nc 15 1)
      has_user=$($icmd user list | grep maas | awk '{ print $1}')
      if [ "$has_user" != "" ]; then
        $icmd user set password $has_user $powerpass
      else
       maxnum=$($icmd user list | tail -1 | awk '{ print $1}')
       $icmd user set name $((maxnum + 1)) maas
       $icmd user set password $((maxnum + 1)) $powerpass
       $icmd channel setaccess $((maxnum + 1)) link=on ipmi=on callin=on privilege=4
       ipmitool user enable $((maxnum + 1))
      fi

      maas $cluster node update $node_id \
      power_type=$powertype \
      power_parameters_power_driver=LAN_2_0 \
      power_parameters_power_address=$powerip \
      power_parameters_power_user=maas \
      power_parameters_power_pass=$powerpass > /dev/null

   ;;
   'amt')
      maas $cluster node update $node_id \
      power_type=$powertype \
      power_parameters_power_address=$powerip \
      power_parameters_power_pass=$powerpass > /dev/null
   ;;
   'virsh')
      powerpass=$3
      maas $cluster node update $node_id \
      power_type=$powertype \
      power_parameters_power_address=$powerip \
      power_parameters_power_id=$powerid \
      power_parameters_power_pass=$powerpass > /dev/null
   ;;
  esac
}

node_tag() {
  tag=$1
  maas $cluster tags list | grep -q $tag || maas $cluster tags new name=$tag > /dev/null
  maas $cluster tag update-nodes $tag add=$node_id > /dev/null
}

node_zone() {
  zone=$1
  maas $cluster zones read | grep -q $zone || maas $cluster zones create name=$zone > /dev/null
  maas $cluster node update $node_id zone=$zone> /dev/null
}

node_commission() {
  maas $cluster node commission $node_id > /dev/null
}

cluster_set() {
  cluster=$1
  force_nodes=$2
}

cluster_login() {
  maas login $cluster http://localhost/MAAS/api/1.0 $MAAS_APIKEY  > /dev/null
}

cluster_logout() {
  maas logout $cluster
}

cluster_set "{{ pillar.enlist.cluster }}" "{{ pillar.enlist.force_nodes }}"
cluster_login
{% for node in pillar.enlist.nodes %}
{%- if node.maas  %}
if node_create "{{ node.name }}" "{{ node.mac }}" amd64 {{ node.sub }}; then
  node_power "{{ node.powertype }}" "{{ node.poweraddress }}" "{{ node.powerpass }}" "{{ node.powerid }}"
{%- if node.zone|length > 0 %}
  node_zone "{{ node.zone }}"
{%- endif -%}
{% if node.partitions|length > 0 %}
  node_tag "{{ node.partitions }}"
{%- endif -%}
{% if pillar.enlist.commission %}
  node_commission
{%- endif -%}
{% endif %}
fi
{% endfor %}
cluster_logout

