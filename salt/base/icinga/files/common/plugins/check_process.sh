#!/bin/bash

LC_NUMERIC=C

C=""
M=""
P=""

CRITICAL=0
WARNING=0
PROC=0
EXITCODE=0
MEMWARN=0
MEMCRIT=0
PROCWARN=0
PROCCRIT=0
NOPROCCRIT=0
DEBUG=0

function Usage {
        echo "
        This script looks at a command and its processes and calculates its CPU and memory usage

        OPTIONS:
        -p - The process name to look for
        -c - The warning to use for the CPU percentage used
        -C - The critical to use for the CPU percentage used
        -m - The warning to use for the Memory percentage used
        -M - The critical to use for the Memory percentage used
        -n - The warning to use for the number of processes
        -N - The critical to use for the number of processes
        -z - Return critical process count is zero
        -d - Produce debug output of either cpu:mem:vsz:rss
        -h - this help

        EXAMPLES:
                Check the usage for apache processes and alert warning if over 80% CPU utilised and critical if 90%
                ./check_cpu_proc.sh -p apache2 -c 80 -C 90

                Check the usage for nagios processes and alert warning if over 20% memory Utilised and critical if 30%
                ./check_cpu_proc.sh -p nagios -m 20 -M 30
"
        exit 3
}

function log {

  if [ "$2" == "$DEBUG" ]; then
#    pid=$1
#    type=$2
#    value=$3
#    result=$4

    case $2 in
      lines) printf "%s\n" "$3"; return ;;
      cpu|mem) printf "PID %s %s: +%.2f%% = %.2f%%\n" "$1" "$2" "$3" "$4"; return ;;
      rss|vsz) printf "PID %s %s: +%.0fkb = %.0fkb\n" "$1" "$2" "$3" "$4"; return ;;
    esac
  fi


}

if [ ! -f /usr/bin/bc ]; then
  echo "PROCESS CRITICAL: bc program not installed - cannot check!"
  exit 3
fi


while getopts "p:c:C:m:M:n:N:d:zh" OPTION
do
        case $OPTION in
                p) PROC=$OPTARG ;;
                c) WARNING=$OPTARG ;;
                C) CRITICAL=$OPTARG ;;
                m) MEMWARN=$OPTARG ;;
                M) MEMCRIT=$OPTARG ;;
                n) PROCWARN=$OPTARG ;;
                N) PROCCRIT=$OPTARG ;;
                z) NOPROCCRIT=$OPTARG ;;
                d) DEBUG=$OPTARG ;;
                h) Usage ;;
        esac
done;

if [[ $DEBUG != 0 ]] && echo ":cpu:mem:vsz:rss:lines:" | grep -v -q ":$DEBUG:"; then
        echo "Must specify a debug type "
        Usage
fi

if [[ $PROC == 0 ]]; then
        echo "Must specify a process name"
        Usage
fi

PSFIELDS="user,pid,ppid,%cpu,%mem,cgroup,vsz,rss,command"
PSPIDLIST=$(sudo pgrep --ns 1 -d',' ${PROC})

if [ "${PSPIDLIST}" == "" ]; then
  read OVERALCPU OVERALMEM OVERALRSS OVERALVSZ COUNT <<< "0 0 0 0 0"
else
  read OVERALCPU OVERALMEM OVERALRSS OVERALVSZ COUNT <<< $(ps -hup ${PSPIDLIST} | awk '
  BEGIN{
    OCPU=0
    OMEM=0
    OVSZ=0
    ORSS=0
  }
  {
    OCPU=OCPU+$3
    OMEM=OMEM+$4
    OVSZ=OVSZ+$5
    ORSS=ORSS+$6
  }
  END{
    print OCPU,OMEM,OVSZ,ORSS,NR
  }')
fi

if [ $WARNING != 0 ] || [ $CRITICAL != 0 ]; then
        if [ $WARNING == 0 ] || [ $CRITICAL == 0 ]; then
                echo "Must Specify both warning and critical"
                Usage
        fi

        #Work out CPU
        if [ `echo $OVERALCPU'>'$WARNING | bc -l` == 1 ]; then
                #echo $OVERALCPU'>'$WARNING
                #echo $OVERALCPU'>'$WARNING | bc -l
                EXITCODE=1
                C="(!$WARNING%%)"

                if [ `echo $OVERALCPU'>'$CRITICAL | bc -l` == 1 ]; then
                        #echo $OVERALCPU'>'$CRITICAL
                        #echo $OVERALCPU'>'$CRITICAL | bc -l
                        EXITCODE=2
                        C="(!$CRITICAL%%)"
                fi
        fi
fi

if [ $MEMWARN != 0 ] || [ $MEMCRIT != 0 ]; then
        if [ $MEMWARN == 0 ] || [ $MEMCRIT == 0 ]; then
                echo "Must Specify both warning and critical"
                Usage
        fi

        #Work out Memory
        if [ `echo $OVERALMEM'>'$MEMWARN | bc -l` == 1 ]; then
                #echo $OVERALCPU'>'$WARNING
                #echo $OVERALCPU'>'$WARNING | bc -l
                EXITCODE=1
                M="(!$MEMWARN%%)"

                if [ `echo $OVERALMEM'>'$MEMCRIT | bc -l` == 1 ]; then
                        #echo $OVERALCPU'>'$CRITICAL
                        #echo $OVERALCPU'>'$CRITICAL | bc -l
                        EXITCODE=2
                        M="(!$MEMCRIT%%)"
                fi
        fi
fi

if [ $PROCWARN != 0 ] || [ $PROCCRIT != 0 ]; then
        if [ $PROCWARN == 0 ] || [ $PROCCRIT == 0 ]; then
                echo "Must Specify both process count warning and critical"
                Usage
        fi

        #Check number of processes
        if [ $COUNT -gt $PROCWARN ]; then
                EXITCODE=1
                P="(!$PROCWARN)"

                if [ $COUNT -gt $PROCCRIT ]; then
                        EXITCODE=2
                        P="(!$PROCCRIT)"
                fi
        fi
fi

if [ $COUNT -eq 0 ]; then
        P="(!)"
        EXITCODE=2
fi


EXITTEXT="OK"

case "$EXITCODE" in
        1) EXITTEXT="WARNING" ;;
        2) EXITTEXT="CRITICAL" ;;
        3) EXITTEXT="UNKNOWN" ;;
esac


IFS="${OIFS}"

printf -v NAGSTAT "PROCESS ${EXITTEXT}: ${PROC} CPU %.2f%%${C} MEM %.2f%%${M} over ${COUNT}${P} processes" "${OVERALCPU}" "${OVERALMEM}"
printf -v PERF "proc=%s;%s;%s cpu=%.2f%%;%s;%s" $COUNT $PROCWARN $PROCCRIT $OVERALCPU $WARNING $CRITICAL
printf -v PERFMEM "mem=%.2f%%;%s;%s rss=%.0fKB vsz=%.0fKB" $OVERALMEM $MEMWARN $MEMCRIT $OVERALRSS $OVERALVSZ

echo "${NAGSTAT} | ${PERF} ${PERFMEM}"

exit $EXITCODE
