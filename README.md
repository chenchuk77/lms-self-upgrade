
This project is a self upgrader for lms service.

features
1. parallel upgrade (avoid restart) / bg process
2. support lms distributed systems (prod/stage) and lms-allinone system (e2e)
3. enable rollback
4. support multiple servers (example: frontend1 and frontend2)
5. use IAM special user
6. remote logging
7. support restart (optionally) default=no


# check :
if bg process where to log ? aws-service ? tcp dedicated srv ?
log to elastic-search https://makeitnew.io/log-to-elasticsearch-using-curl-db8bf8ef2785
ask olivier if open from any source

script execution :

./do-upgrade --bucket {} --war {lms|rating|api-gw|frontend|auth|messaging-worker|MtsSdpSolutionApi|sms-broker|charging-worker} [--tenant {MTN_NG|MTN_CI|AIRTEL_NG|LAB_NETANYA}]

./do-upgrade --s3 lms-releases/J2/OD/L15.00.00 --war lms
./do-upgrade --s3 lms-releases/J2/OD/L15.00.00 --war MtsSdpSolutionApi --tenant MTN_NG



