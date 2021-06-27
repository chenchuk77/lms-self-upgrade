#!/bin/bash

# this is a starter script for a tester. its wrap the tester.sh 
# in the same way run.sh wraps the self-upgrade.sh script
# if everything is ok, this will start a background process 
# that prints the date+args every 1 sec for 10 minutes.
# chech the debug folder to see if the process is running.
#
# 1. its run in background
# 2. keep its running as daemon when parent teminal terminates
#

TIMESTAMP=$(date +%s%N)
TESTER_DEBUG_LOG_FILE=debug/debug.tester.${TIMESTAMP}.log

nohup ./tester.sh "$@" > ${TESTER_DEBUG_LOG_FILE} 2>&1 &

#############################################################################
#
# example :
#
# ./run-tester.sh --s3 xxx --war yyy --tenant zzz
#
