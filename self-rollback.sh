#!/bin/bash

# This script is used for self-upgrade for lms services.
# it designed to run as a daemon process, and allows multiple instances to run in parallel.
# each instance has its own workspace and environment which allows this behavior.

echo "script not ready yet. exiting..."
exit 0

# import functions
source ./functions.sh

# load aws credentials
source ./credentials/credentials.aws


###############################################################################
# consts
#
#
SELFUPGRADE_HOST=$(curl ifconfig.io)
SELFUPGRADE_HOME=/opt/self-upgrade
VALID_TENANTS=("MTN_NG" "MTN_CI" "AIRTEL_NG" "LAB_NETANYA")
VALID_CORE_WARS=("lms" "rating" "api-gw" "frontend" "auth")
VALID_TENANT_WARS=("messaging-worker" "MtsSdpSolutionApi" "sms-broker" "charging-worker")
VALID_WARS=("${VALID_CORE_WARS[@]}" "${VALID_TENANT_WARS[@]}")

###############################################################################
# vars
#
# TS: timestamp for uniquely identify this execution (among with pid). 
# TS: will be used for rollback.
# WORKSPACE: 
# LMS_TYPE: folder structure depends on this.
#
TS=$(date +%s)
#WORKSPACE=${SELFUPGRADE_HOME}/workspaces/${TS}-$$
WORKSPACE=/tmp/workspace/${TS}-$$
BACKUP_FOLDER=${SELFUPGRADE_HOME}/backups/${TS}-$$
LMS_TYPE=$(set_lms_type)
ELK_INDEX="lms-self-upgrade-$(date +%Y-%m)"

###############################################################################
# args
#
# S3_BUCKET: {--s3}     - s3 path of the lms-release to deploy.
# WAR:       {--war}    - the tomcat-webapp to be upgraded.
# TENANT:    [--tenant] - optional: the tenant to be upgraded.
# ELK_HOST:  [--elk]    - the elastic-search host (for remote logging).
#
S3_BUCKET=
WAR=
TENANT=
ELK_HOST=

###############################################################################
# main
#
read_args
input_validation
setup_environment
set_tomcat_home

log "starting a new lms-self-upgrade process with id: ${TS}-$$."
log "process will upgrade the webapp: ${WAR}."
log "source s3 busket: ${S3_BUCKET}."
log "this lms is : ${LMS_TYPE}." 
log "using TOMCAT_HOME=${TOMCAT_HOME}."

download_artifact
disable_watchdogs

# check allinone
stop_tomcat
backup_tomcat
delete_webapp
upgrade_webapp
start_tomcat
enable_watchdog



