#!/usr/bin/env bash

SCRIPTDIR=$(dirname $0)
. $SCRIPTDIR/lib/webserver
. $SCRIPTDIR/lib/steps

description="Steps to ensure the basic services salt, repo and DNS are up and running"
steps[0]="minimal:Install the repository and dns server"
steps[1]="shining:Make the new world shine - apply states to the new machines"
steps[2]="finish:Enforce the basic services are configured and available"

minit $STEP

wsstart

if action minimal; then
  salt \*.cde.1nc state.sls core.roles
  salt \*.cde.1nc state.sls core.sync
  salt \*.cde.1nc saltutil.pillar_refresh
  salt \*.cde.1nc state.sls system.upgrade
  salt repo-a1.cde.1nc state.sls repo
  salt micros-a1.cde.1nc state.sls bind
  salt-run nodes.gen_dns cde
  salt micros-a1.cde.1nc state.sls dhcpd
  salt-run nodes.gen_dhcp cde
fi

if action shining; then
  salt \*.cde.1nc state.sls core.resolver pillar='{"bootstrap": True}'
  salt \*.cde.1nc state.sls core pillar='{"bootstrap": True}'
  salt \*.cde.1nc state.sls debug.unlocked
  salt \*.cde.1nc state.sls sshd
fi

if action finish; then
  # reinstall and enforce our services
  salt \*.cde.1nc saltutil.pillar_refresh
  salt repo-a1.cde.1nc state.sls repo
  salt micros-a1.cde.1nc state.sls bind
  salt-run nodes.gen_dns cde
  salt micros-a1.cde.1nc state.sls dhcpd
  salt-run nodes.gen_dhcp cde
fi

wsstop

