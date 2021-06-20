#!/bin/bash

# This file is contains functions,
# it should be sourced from the self-upgrade.sh script.

function log {
  MESSAGE=$1
  echo $MESSAGE
  CURL_JSON="{host-id: {$HOST_ID}, msg: ${MESSAGE}}"
  # TODO: curl to elastic search for logging
}

function read_args {
  POSITIONAL=()
  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
      --s3)
        S3_BUCKET="$2"
        shift; shift ;;
      --war)
        WAR="$2"
        shift; shift ;;
      --tenant)
        TENANT="$2"
        shift; shift ;;
      --elk)
        ELK_HOST="$2"
        shift; shift ;;
      --default)
        DEFAULT=YES
        shift # past argument
        ;;
      *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        log "invalid proecss arguments:"
        log "$@"
	exit 99
	shift # past argument
        ;;
    esac
  done
}

function input_validation {
  if [[ -z "${S3_BUCKET}" ]]; then
    log "missing s3 bucket of lms release."
    exit 98
  fi

  if [[ -z "${WAR}" ]]; then
    log "missing war name."
    exit 97
  fi

  if ! in_list("${WAR}" "${VALID_WARS[@]}"); then 
    log "the war: ${WAR} is not supported."
    exit 96
  fi

  if [[ -z "${TENANT}" ]]; then
    if in_list("${WAR}" "${VALID_TENANT_WARS[@]}"); then
      log "the war: ${WAR} must be used with a tenant."
      exit 95
    fi
  else
    if in_list("${WAR}" "${VALID_CORE_WARS[@]}"); then
      log "the war: ${WAR} is a core service and should not used with a tenant."
      exit 94
    fi
  fi

  if [[ ! -z "${ELK_HOST}" ]]; then
    if [[ ! "${ELK_HOST}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      log "the elk address ${ELK_HOST} is invalid."
      exit 93
    fi
  fi
  log "input parameters validation passed."
}

function in_list {
  # helper function to check if element $1 exists in array $2
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

function set_lms_type {
  if [[ -d /opt/lms/apache-tomcat-7.core ]]; then
    LMS_TYPE="ALLINONE"
  else
    LMS_TYPE="DISTRIBUTED"
  fi
}

function set_tomcat_home {
  # distributed lms. tomcat in same place
  if [[ "${LMS_TYPE}" == "DISTRIBUTED" ]]; then
    TOMCAT_HOME=/opt/lms/apache-tomcat-7
  else
    # allinone lms has multiple tomcat instances.
    if in_list("${WAR}" "${VALID_CORE_WARS[@]}"); then
      TOMCAT_HOME=/opt/lms/apache-tomcat-7.core
    else
      TOMCAT_HOME=/opt/lms/apache-tomcat-7.${TENANT}
    fi
  fi
}

function backup_tomcat {
  cp ${TOMCAT_HOME}/webapps/${WAR}.war ${WORKSPACE}
  cp ${TOMCAT_HOME}/conf/Catalina/localhost/xxx.xml ${WORKSPACE}
}

function delete_webapps {
  rm -rf ${TOMCAT_HOME}/work/*
  rm -rf ${TOMCAT_HOME}/temp/*
  rm -rf ${TOMCAT_HOME}/webapps/${WAR}
  rm -rf ${TOMCAT_HOME}/webapps/${WAR}.war
}


function disable_watchdogs {
  if systemctl is-active --quiet cron.service; then
    systemctl stop cron.service
    log "cron stopped."
  else
    log "cron is not running."
  fi
  if systemctl is-active --quiet monit.service; then 
    systemctl stop monit.service
    log "monit stopped."
  else
    log "monit is not running."
  fi
}

function enable_watchdogs {
  if systemctl is-active --quiet monit.service; then  
    log "monit is already running."
  else
    systemctl start monit.service
    log "monit started."
  fi
  if systemctl is-active --quiet cron.service; then
    log "cron is already running."
  else
    systemctl stop cron.service
    log "cron started."
  fi
}

function download_artifact {
  aws s3 cp s3://${S3_BUCKET}/${WAR}.war $2 --quiet
    
}
