#!/bin/bash

# This script is used for self-upgrade for lms services.
# it designed to run as a daemon process, and allows multiple instances to run in parallel.
# each instance has its own workspace, allowing this behavior.

echo "not ready"
exit 0






# consts
SELFUPDATE_HOME=/opt/self-update
WORKSPACE=${SELFUPDATE_HOME}/backups/${TS}-$$
VALID_CORE_WARS=("lms" "rating" "api-gw" "frontend" "auth")
VALID_TENANT_WARS=("messaging-worker" "MtsSdpSolutionApi" "sms-broker" "charging-worker")
VALID_WARS=("${VALID_CORE_WARS[@]}" "${VALID_TENANT_WARS[@]}")


# vars
TS=$(date +%s)
S3_BUCKET=
WAR=
TENANT=
ELK_HOST=

# functions
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
  if [[ -z "S3_BUCKET" ]]; then
    log "missing s3 bucket of lms release."
    exit 98
  fi

  if [[ -z "WAR" ]]; then
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


#irx='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'

}

function in_list {
  # helper function to check if element $1 doesnt exists in array $2
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}



function set_tomcat_home {
  if [[ -z "${TENANT}" ]]; then
    TOMCAT_HOME=/opt/lms/apache-tomcat-7
  elif
    TOMCAT_HOME=/opt/lms/apache-tomcat-${TENANT}
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


function 

./self-upgrade.sh {source-bucket} {service-name}


backend
frontend


HOST_ID="$(hostname)-$(curl ifconfig.io)"
TS=$(date +%s)
log "starting a new self-upgrade process with pid $$."
log "self-upgrade 
log "source-ip:$(curl ifconfig.io) process starts with pid: $$, artifacts timestamp will be ${TS}"

# from args
S3_BUCKET=my_bucket
WAR=
TENANT=

# consts
# WORKSPACE is unique with TS and PID. this allows allinone to start multiple
# processes in the background, each will have its own folder.
WORKSPACE=${SELFUPDATE_HOME}/backups/${TS}-$$
SELFUPDATE_HOME=/opt/self-update


mkdir -p ${WORKSPACE}

get_tomcat_home
log "using TOMCAT_HOME=${TOMCAT_HOME}."

#backup_webapps
cp ${TOMCAT_HOME}/webapps/${WAR}.war ${WORKSPACE}
cp ${TOMCAT_HOME}/conf/Catalina/localhost/xxx.xml ${WORKSPACE}

#delete_webapps
rm -rf ${TOMCAT_HOME}/work/*
rm -rf ${TOMCAT_HOME}/temp/*
rm -rf ${TOMCAT_HOME}/webapps/${WAR}
rm -rf ${TOMCAT_HOME}/webapps/${WAR}.war




