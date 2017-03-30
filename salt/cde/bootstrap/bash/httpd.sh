#!/bin/bash

. /srv/salt/cde/bootstrap/bash/lib/webserver

wsstart

read -p "Waiting for you to end me ..."

wsstop
