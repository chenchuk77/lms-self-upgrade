#!/bin/bash

# This file is contains functions,
# it should be sourced from the self-upgrade.sh script.

function random_delay {
  FEW_SECONDS=$(shuf -i 2-10 -n 1)
  #FEW_SECONFS=$((1 + $RANDOM % 10))
  log "process will start in ${FEW_SECONDS} seconds ..."
  sleep ${FEW_SECONDS}s
}


function in_list {
  # check if item $1 in list $2
  ITEM_AND_LIST=("$@")
  ITEM="${ITEM_AND_LIST[0]}"
  LIST=("${ITEM_AND_LIST[@]}")
  unset LIST[0]
  for ELEMENT in ${LIST[@]}; do
    if [[ "${ELEMENT}" == "${ITEM}"  ]]; then
      return 0
    fi
  done
  return 1
}

function count_processes {
  # this will be used to conditionally restart tomcat only if its the last webapp (among other processes).
  # it returns the number of active self-upgrade processes.
  # in allinone systems it returns the number of processes for the current tenant only.
  if [[ "${LMS_TYPE}" == "DISTRIBUTED" ]]; then
    NUM_PROC=$(ps -ef | grep "$0" | grep -v grep | wc -l)
  else
    if [[ -z "${TENANT}" ]]; then
      NUM_PROC=$(ps -ef | grep "$0" | grep core | grep -v grep | wc -l)     
    else
      NUM_PROC=$(ps -ef | grep "$0" | grep ${TENANT} | grep -v grep | wc -l)     
    fi
  fi
  echo -n "${NUM_PROC}"
}

