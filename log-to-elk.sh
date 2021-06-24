#!/bin/bash

# use this tool to check elk logging

### VARS
TS=$(date +%s)
HOST=$(curl -ss ifconfig.io)
PID=$$

# load aws credentials
source ./credentials/credentials.elk

function log {
  MESSAGE_TEXT=$1
  MESSAGE_DATE=$(date '+%Y/%m/%d %H:%M:%S')
  echo "${MESSAGE_DATE} [${TS}-${PID}] : ${MESSAGE_TEXT}"

  if [[ ! -z "${ELK_HOST}" ]]; then
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
}

log "this is a test message [$$] from log-to-elk.sh testing tool"




