#!/bin/bash

# This file is contains functions,
# it should be sourced from the self-upgrade.sh script.

#function log {
#  MESSAGE=$1
#  echo $MESSAGE
#  CURL_JSON="{host-id: {$HOST_ID}, msg: ${MESSAGE}}"
#  # TODO: curl to elastic search for logging
#}

function log {
  set +x
  MESSAGE_TEXT=$1
  MESSAGE_DATE=$(date '+%Y/%m/%d %H:%M:%S')
  echo "${MESSAGE_DATE} [${TS}-${PID}] : ${MESSAGE_TEXT}" >> ${SELFUPGRADE_HOME}/upgrader.log

  if [[ ! -z "${ELK_URL}" ]]; then
    # logging also to remote elastic-search
    curl -u ${ELK_USER}:${ELK_PASSWORD} \
            ${ELK_URL}/${ELK_INDEX}/_doc \
           -XPOST \
           -H 'Content-Type: application/json' \
           -d "$(cat <<EOF
{
  "pid": "${PID}",
  "process_ts": "${TS}",
  "unique_id": "${TS}-${PID}",
  "client_ip": "${HOST}",
  "message_time": "${MESSAGE_DATE}",
  "message_text": "${MESSAGE_TEXT}"
}
EOF
                )" >> /dev/null 2>&1
  fi
  set -x
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

  if ! in_list "${WAR}" "${VALID_WARS[@]}"; then 
    log "the war: ${WAR} is not supported."
    exit 96
  fi

  if [[ -z "${TENANT}" ]]; then
    if in_list "${WAR}" "${VALID_TENANT_WARS[@]}"; then
      log "the war: ${WAR} must be used with a tenant."
      exit 95
    fi
  else
    if in_list "${TENANT}" "${VALID_TENANTS[@]}"; then
      log "the tenant: ${TENANT} is not supported. valid tenants are [ ${VALID_TENANTS[@]} ]."
      exit 94
    fi

    if in_listi "${WAR}" "${VALID_CORE_WARS[@]}"; then
      log "the war: ${WAR} is a core service and should not used with a tenant."
      exit 93
    fi
  fi

  if [[ ! -z "${ELK_HOST}" ]]; then
    if [[ ! "${ELK_HOST}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      log "the elk address ${ELK_HOST} is invalid."
      exit 92
    fi
  fi
  log "input parameters validation passed."
}

function setup_environment {
  mkdir -p ${WORKSPACE}
  mkdir -p ${BACKUP_FOLDER}
  log "execution folders created for ${TS}-$$."
}

function get_lms_type {
  if [[ -d /opt/lms/apache-tomcat-7.core ]]; then
    LMS_TYPE="ALLINONE"
  else
    LMS_TYPE="DISTRIBUTED"
  fi
  echo "${LMS_TYPE}"
}

function get_tomcat_home {
  # distributed lms. tomcat in same place
  if [[ "${LMS_TYPE}" == "DISTRIBUTED" ]]; then
    TOMCAT_HOME=/opt/lms/apache-tomcat-7
  else
    # allinone lms has multiple tomcat instances.
    if in_list "${WAR}" "${VALID_CORE_WARS[@]}"; then
      TOMCAT_HOME=/opt/lms/apache-tomcat-7.core
    else
      TOMCAT_HOME=/opt/lms/apache-tomcat-7.${TENANT}
    fi
  fi
  echo "${TOMCAT_HOME}"
}

function backup_tomcat {
  cp ${TOMCAT_HOME}/webapps/${WAR}.war ${BACKUP_FOLDER}
  if [[ -f "${TOMCAT_HOME}/conf/Catalina/localhost/${WAR}.xml" ]]; then
    cp ${TOMCAT_HOME}/conf/Catalina/localhost/${WAR}.xml ${BACKUP_FOLDER}
  fi
  log "old war saved into ${BACKUP_FOLDER}"
}

function delete_webapp {
  rm -rf ${TOMCAT_HOME}/work/*
  rm -rf ${TOMCAT_HOME}/temp/*
  rm -rf ${TOMCAT_HOME}/webapps/${WAR}
  rm -rf ${TOMCAT_HOME}/webapps/${WAR}.war
}

function upgrade_webapp {
  cp ${WORKSPACE}/${WAR}.war ${TOMCAT_HOME}/webapps
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
    systemctl start cron.service
    log "cron started."
  fi
}

function start_tomcat {
  # set systemd unit name
  if [[ "${LMS_TYPE}" == "ALLINONE" ]]; then
    if in_list "${WAR}" "${VALID_CORE_WARS[@]}"; then
      TOMCAT_SERVICE_NAME=tomcat.core.service
    else
      TOMCAT_SERVICE_NAME=tomcat.${TENANT}.service
    fi
  else
    TOMCAT_SERVICE_NAME=tomcat.service
  fi
  # start systemd unit
  if systemctl is-active --quiet ${TOMCAT_SERVICE_NAME}; then
    log "${TOMCAT_SERVICE_NAME} is already running."
  else
    systemctl start ${TOMCAT_SERVICE_NAME}
    log "${TOMCAT_SERVICE_NAME} started."
  fi
}

function stop_tomcat {
  # set systemd unit name
  if [[ "${LMS_TYPE}" == "ALLINONE" ]]; then
    if in_list "${WAR}" "${VALID_CORE_WARS[@]}"; then
      TOMCAT_SERVICE_NAME=tomcat.core.service
    else
      TOMCAT_SERVICE_NAME=tomcat.${TENANT}.service
    fi
  else
    TOMCAT_SERVICE_NAME=tomcat.service
  fi
  # stop systemd unit
  if systemctl is-active --quiet ${TOMCAT_SERVICE_NAME}; then
    log "stopping ${TOMCAT_SERVICE_NAME} ...."
    systemctl stop ${TOMCAT_SERVICE_NAME}  
    while [ $? -ne 0 ]; do
      # wait until success
      log "stopping ${TOMCAT_SERVICE_NAME} failed, retry in 10s"
      sleep 10s
      systemctl stop ${TOMCAT_SERVICE_NAME}  
    done
    log "${TOMCAT_SERVICE_NAME} stopped."
  else
    STILL_ACTIVE_TOMCAT=$(ps -ef | grep tomcat | grep core | wc -l)
    while [[ "${STILL_ACTIVE_TOMCAT}" == "1" ]]; do
      log "tomcat is still going down ... waiting 10s ..."
      sleep 10s
    done
    log "${TOMCAT_SERVICE_NAME} is not running."
  fi
}

function download_artifact {
  log "downolading ${WAR} from ${S3_BUCKET} ..."
  aws s3 cp s3://${S3_BUCKET}/${WAR}.war ${WORKSPACE} --quiet
  log "download finished successfuly."
}

function hello {
  echo hello
}


