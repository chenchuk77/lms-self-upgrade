#!/bin/bash

./self-upgrade.sh {source-bucket} {service-name}


backend
frontend

function log {
 MESSAGE=$1
 echo $MESSAGE
 # TODO: curl to elastic search for logging
}



TS=$(date +%s)

log "source-ip:$(curl ifconfig.io) process starts with pid: $$, artifacts timestamp will be ${TS}"

S3_BUCKET=my_bucket
SELFUPDATE_HOME=/opt/self-update


# WORKSPACE is unique with TS and PID. this allows allinone to start multiple
# processes in the background, each will have its own folder.
WORKSPACE=${SELFUPDATE_HOME}/backups/${TS}-$$
mkdir -p ${WORKSPACE}

TOMCAT_HOME=/opt/lms/apache-tomcat-7

cp ${TOMCAT_HOME}/webapps/lms.war ${WORKSPACE}
cp ${TOMCAT_HOME}/conf/Catalina/localhost/xxx.xml ${WORKSPACE}

rm -rf ${TOMCAT_HOME}/work/*
rm -rf ${TOMCAT_HOME}/temp/*
rm -rf ${TOMCAT_HOME}/webapps/lms
rm -rf ${TOMCAT_HOME}/webapps/lms.war




