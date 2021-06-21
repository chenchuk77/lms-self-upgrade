#!/bin/bash

UNIQUE_ID=$1


# fetching logs of this month ONLY
ELK_INDEX="lms-self-upgrade-$(date +%Y-%m)"

# load aws credentials
source ./credentials.elk

function get_all_logs {
  curl -u ${ELK_USER}:${ELK_PASSWORD} \
          ${ELK_URL}/${ELK_INDEX}/_doc/_search/?size=1000\&pretty=true \
          -H 'Content-Type: application/json' \
          -d '{    "query": {
        "query_string": {"query": "*"}
    }
}' | jq '.hits.hits[]._source | [.unique_id, .client_ip, .message_text ] | @csv' | tr -d '"\\'

}



get_all_logs
