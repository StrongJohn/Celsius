#!/usr/bin/env bash

#Licensed under MIT
#Copyright (c) 2015 StrongJohn (https://github.com/StrongJohn)
#Celsius is a script to log temperatures for FreeNAS systems.
#This script is in development and is not intended for public use.

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd ) #sets working directory to script location.

#Checks for/creates a Log folder and files for celsius.
mkdir -p -m 775 $DIR/log
touch $DIR/log/cputemp.txt; chmod 664 $DIR/log/cputemp.txt
touch $DIR/log/hddtemp.txt; chmod 664 $DIR/log/hddtemp.txt
#Timestamp Logs
echo $(date +%F_%T) | tee -a $DIR/log/cputemp.txt $DIR/log/hddtemp.txt > /dev/null
#CPU temperature
sysctl -a |egrep -E "cpu\.[0-9]+\.temp" >> $DIR/log/cputemp.txt

#adastat Start
LOGFILE=$DIR/log/hddtemp.txt
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
echo "Drive Activity Status" >> $DIR/log/hddtemp.txt
for i in $(sysctl -n kern.disks | awk '{for (i=NF; i!=0 ; i--) if(match($i, '/ada/')) print $i }' ); do echo -n $i:; adastat $i; done; echo ; echo >> $DIR/log/hddtemp.txt
echo "HDD Temperature:" >> $DIR/log/hddtemp.txt
for i in $(sysctl -n kern.disks | awk '{for (i=NF; i!=0 ; i--) if(match($i, '/ada/')) print $i }' )
do
   echo $i `smartctl -a /dev/$i | awk '/Temperature_Celsius/{DevTemp=$10;} /Serial Number:/{DevSerNum=$3}; /Device Model:/{DevName=$3} END { print DevTemp,DevSerNum,DevName }'` >> $DIR/log/hddtemp.txt
done
echo >> $DIR/log/hddtemp.txt
