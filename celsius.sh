#!/usr/bin/env bash

#Licensed under MIT
#Copyright (c) 2015 StrongJohn (https://github.com/StrongJohn)
#Celsius is a script to log temperatures for FreeNAS systems.
#This script is in development and is not intended for public use.

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd ) #sets working directory to script location.
LOG=$DIR/log.txt

#Creates a log file if not present
touch $LOG; chmod 664 $LOG

#Timestamp Logs
echo $(date +%F_%T) >> $LOG
#CPU temperature
sysctl -a |egrep -E "cpu\.[0-9]+\.temp" >> $LOG

#adastat Start
LOGFILE=$LOG
adastat () {
  CM=$(camcontrol cmd $1 -a "E5 00 00 00 00 00 00 00 00 00 00 00" -r - | awk '{print $10}')
  if [ "$CM" = "FF" ] ; then
  echo "$1:SPINNING" >> $LOGFILE
  elif [ "$CM" = "00" ] ; then
  echo "$1:IDLE" >> $LOGFILE
  else
  echo "$1:UNKNOWN ($CM)" >> $LOGFILE
  fi
}
#adastat End


#HDD temperature
echo "Drive Activity Status" >> $LOG
for i in $(sysctl -n kern.disks | awk '{for (i=NF; i!=0 ; i--) if(match($i, '/ada/')) print $i }' ); do echo -n $i:; adastat $i; done; echo ; echo >> $LOG
echo "HDD Temperature:" >> $LOG
for i in $(sysctl -n kern.disks | awk '{for (i=NF; i!=0 ; i--) if(match($i, '/ada/')) print $i }' )
do
   echo $i `smartctl -a /dev/$i | awk '/Temperature_Celsius/{DevTemp=$10;} /Serial Number:/{DevSerNum=$3}; /Device Model:/{DevName=$3} END { print DevTemp,DevSerNum,DevName }'` >> $LOG
done
echo >> $LOG
