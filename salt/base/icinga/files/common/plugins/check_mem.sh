#!/bin/bash

usage() {
        echo "check_mem v1.4"
        echo ""
        echo "Usage:"
        echo "check_mem.sh -w <warnlevel> -c <critlevel>"
        echo ""
        echo "warnlevel and critlevel is percentage value without %"
        echo ""
        echo "v1.1 Copyright (C) 2012 Lukasz Gogolin (lukasz.gogolin@gmail.com)"
        echo "v1.2 Modified 2014 by Aaron Roydhouse (aaron@roydhouse.com)"
        echo "v1.3 Modified 2015 by Aaron Roydhouse (aaron@roydhouse.com)"
        echo "v1.3 Modified 2016 by Clemens Perz (clemens@1-net.com.sg)"
        exit 3
}

WARN=0
CRIT=0

while getopts "w:c:" OPTION
do
        case $OPTION in
                w) WARN=$OPTARG ;;
                c) CRIT=$OPTARG ;;
                h) Usage ;;
        esac
done;

if [ $WARN -eq 0 ] || [ $CRIT -eq 0 ]; then
  usage
fi

freem=`free -m | grep Mem`
freem_bits=(${freem// / })

memTotal_m=${freem_bits[1]}
memFree_m=${freem_bits[3]}
memBuffer_m=${freem_bits[5]}
memCache_m=${freem_bits[6]}

memUsed_m=$(($memTotal_m-$memFree_m-$memBuffer_m-$memCache_m))
memUsedPrc=$((($memUsed_m*100)/$memTotal_m))

warn=$(((($memTotal_m*100)-($memTotal_m*(100-$2)))/100))
crit=$(((($memTotal_m*100)-($memTotal_m*(100-$4)))/100))

memTotal_b=$(($memTotal_m*1024*1024))
memFree_b=$(($memFree_m*1024*1024))
memUsed_b=$(($memUsed_m*1024*1024))
memBuffer_b=$(($memBuffer_m*1024*1024))
memCache_b=$(($memCache_m*1024*1024))

minmax="0;$memTotal_b";
data="TOTAL=${memTotal_b}B;;;${minmax} USED=${memUsed_b}B;$warn;$crit;$minmax CACHE=${memCache_b}B;;;$minmax BUFFER=${memBuffer_b}B;;;$minmax"

      if [ "$memUsedPrc" -ge "$CRIT" ]; then
              echo "MEMORY CRITICAL - Total: $memTotal_m MB - Used: $memUsed_m MB - $memUsedPrc% used!|$data"
              $(exit 2)
      elif [ "$memUsedPrc" -ge "$WARN" ]; then
              echo "MEMORY WARNING - Total: $memTotal_m MB - Used: $memUsed_m MB - $memUsedPrc% used!|$data"
              $(exit 1)
      else
              echo "MEMORY OK - Total: $memTotal_m MB - Used: $memUsed_m MB - $memUsedPrc% used|$data"
              $(exit 0)
      fi

