#!/bin/bash

# this is a starter script which ensure the process started correctly :
#
# 1. its run in background
# 2. keep its running as daemon when parent teminal terminates
# 3. provide per-execution low-level bash debug
#
# NOTE : the timestamp of those low-level debugging IS NOT the same as the unique-id of the 
# self-upgrade job ( will be very close )
#

TIMESTAMP=$(date +%s%N)
DEBUG_LOG_FILE=debug/debug.${TIMESTAMP}.log

nohup ./self-upgrade.sh "$@" > ${DEBUG_LOG_FILE} 2>&1 &

#############################################################################
#
# example :
#
# ./run.sh --s3 lms-releases/j3/LMS-BUILD-2004 --war auth
#
