#!/bin/bash

STATE=$1
TEXT="$2"

logger -t tummy "($STATE) $TEXT"

echo "$TEXT"
exit $STATE
