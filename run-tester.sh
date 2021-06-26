#!/bin/bash

# this is a starter script for a tester. its wrap the tester.sh 
# in the same way run.sh wraps the self-upgrade.sh script
#
# 1. its run in background
# 2. keep its running as daemon when parent teminal terminates
#

TIMESTAMP=$(date +%s%N)
TESTER_DEBUG_LOG_FILE=debug/debug.tester.${TIMESTAMP}.log

nohup ./tester.sh > ${TESTER_DEBUG_LOG_FILE} 2>&1 &

#############################################################################
#
# example :
#
# ./run-tester.sh
#
