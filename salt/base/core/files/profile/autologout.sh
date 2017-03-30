#!/bin/sh

# 15 minutes timeout on the console and in remote sessions
TMOUT={{ pillar.defaults.bashtimeout }}
readonly TMOUT
export TMOUT
