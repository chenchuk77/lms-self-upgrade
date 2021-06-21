#!/bin/bash

# This file is contains functions,
# it should be sourced from the self-upgrade.sh script.

function in_list {
  # helper function to check if element $1 exists in array $2
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function count_processes {
  # this will be used to conditionally restart tomcat only if its the last webapp (among other processes).
  # it returns the number of active self-upgrade processes.
  # in allinone systems it returns the number of processes for the current tenant only.
  if [[ "${LMS_TYPE}" == "DISTRIBUTED" ]]; then
    NUM_PROC=$(ps -ef | grep $0 | grep -v grep | wc -l)
  else
    NUM_PROC=$(ps -ef | grep $0 | grep ${TENANT} | grep -v grep | wc -l)     
  fi
  return ${NUM_PROC}
}


