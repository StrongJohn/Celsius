#!/usr/bin/env bash

#Licensed under MIT
#Copyright (c) 2015 StrongJohn (https://github.com/StrongJohn)
#Celsius is a script to log temperatures for FreeNAS systems.
#This script is in development and is not intended for public use.

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )

#Checks for/creates  Log folder in celsius
mkdir -p -m 775 $DIR/log
touch $DIR/log/cputemp.txt; chmod 664 $DIR/log/cputemp.txt

echo $(date +%F_%T) >> $DIR/log/cputemp.txt

sysctl -a |egrep -E "cpu\.[0-9]+\.temp" >> $DIR/log/cputemp.txt