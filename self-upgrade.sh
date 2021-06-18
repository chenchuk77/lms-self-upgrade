#!/bin/bash

# This script is used for self-upgrade for lms services.
# it designed to run as a daemon process, and allows multiple instances to run in parallel.
# each instance has its own workspace and environment which allows this behavior.

echo "script not ready yet. exiting..."
exit 0

# import functions
source ./functions.sh

# consts and vars
LMS_TYPE=$(set_lms_type)
TS=$(date +%s)
SELFUPGRADE_HOST=$(curl ifconfig.io)
SELFUPGRADE_HOME=/opt/self-upgrade
WORKSPACE=${SELFUPDATE_HOME}/backups/${TS}-$$
VALID_CORE_WARS=("lms" "rating" "api-gw" "frontend" "auth")
VALID_TENANT_WARS=("messaging-worker" "MtsSdpSolutionApi" "sms-broker" "charging-worker")
VALID_WARS=("${VALID_CORE_WARS[@]}" "${VALID_TENANT_WARS[@]}")

# args
S3_BUCKET=
WAR=
TENANT=
ELK_HOST=


read_args
inpus_validation
set_lms_type
set_tomcat_home

HOST_ID="$(hostname)-$(curl ifconfig.io)"
TS=$(date +%s)
log "starting a new self-upgrade process with pid $$."
log "self-upgrade 
log "source-ip:$(curl ifconfig.io) process starts with pid: $$, artifacts timestamp will be ${TS}"

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




