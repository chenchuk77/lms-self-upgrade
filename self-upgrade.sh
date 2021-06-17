#!/bin/bash

echo "not ready"
exit 0



./self-upgrade.sh {source-bucket} {service-name}


backend
frontend

function log {
 MESSAGE=$1
 echo $MESSAGE
 # TODO: curl to elastic search for logging
}

function get_tomcat_home {
 if [[ -z "${TENANT}" ]]; then
   TOMCAT_HOME=/opt/lms/apache-tomcat-7
 elif
   TOMCAT_HOME=/opt/lms/apache-tomcat-7-${TENANT}
 fi
}


TS=$(date +%s)

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




