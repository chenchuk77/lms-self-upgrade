#!/bin/bash

# get logs of 10 last minutes
LAST_N_MINUTES=$1
if [[ -z "${LAST_N_MINUTES}" ]]; then
  LAST_N_MINUTES=10  
fi

# fetching logs of this month ONLY
ELK_INDEX="lms-self-upgrade-$(date +%Y-%m)"

# load aws credentials
source ./credentials/credentials.elk

function query {
  cat <<EOF
{
 "query": {
  "range" : {
   "message_time" : {
    "gte" : "now-${LAST_N_MINUTES}m"
   }
  }
 }
}
EOF
}

function get_unique_ids {
  curl -ss -u ${ELK_USER}:${ELK_PASSWORD} \
          ${ELK_URL}/${ELK_INDEX}/_doc/_search/?size=1000\&pretty=true \
          -H 'Content-Type: application/json' \
          -d "$(query)" | jq '.hits.hits[]._source | [.unique_id, .client_ip, .message_text ] | @csv' | \
	     tr -d '"\\' | cut -d ',' -f1 | sort | uniq


}

get_unique_ids ${LAST_N_MINUTES}
