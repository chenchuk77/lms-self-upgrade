#!/bin/bash

UNIQUE_ID=$1

# fetching logs of this month ONLY
ELK_INDEX="lms-self-upgrade-$(date +%Y-%m)"

# load aws credentials
source ./credentials/credentials.elk

function query {
  cat <<EOF
{ 
 "query": {
  "query_string": {
   "query": "*"
  }
 }
}
EOF
}

function get_all_logs {
  curl -ssu ${ELK_USER}:${ELK_PASSWORD} \
          ${ELK_URL}/${ELK_INDEX}/_doc/_search/?size=1000\&pretty=true \
          -H 'Content-Type: application/json' \
	  -d "$(query)" | jq '.hits.hits[]._source | [.unique_id, .client_ip, .message_text ] | @csv' | \
	      tr -d '"\\' | grep "${UNIQUE_ID}"

}

get_all_logs

