
# LMS Self-Upgrade
This project is a self upgrader for lms service.

## Targets:
1. provide a self upgrade capability to LMS servers.
2. enable remote invocation of the process, allowing simple upgrade from central machine.

## Features:
1. parallel upgrade (avoid restart) / bg process
2. support lms distributed systems (prod/stage) and lms-allinone system (e2e)
3. enable rollback
4. support multiple servers (example: frontend1 and frontend2)
5. use IAM special user
6. remote logging via ELK
7. support restart (optionally) default=no

## Unsupported features:
1. configuration changes is not supported. only a stable war replacement mechanism.

## Considerable features:
1. self-upgraded (the script itself) pull from git before execution - this is good because if changing code in script, no need to ssh to all servers for update the code.
2. support LMSDB ???
3. make snapshot before start ?
4. s3 local artifact caching

## TODOs:
1. support restart arg
2. check elk address pattern for regexp
3. get elk integration (olivier)
4. snapshot e2e for testing (on env75)

## Links:
[elk example]: https://makeitnew.io/log-to-elasticsearch-using-curl-db8bf8ef2785

## Instructions:

To upgrade an LMS component, u should SSH to the target machine, and run it.

The target machine can be an ec2 instance with tomcat-7 or allinone host with multiple tomcat-7's.

The script need to accept the path to the lms-release in s3, and the specific war from this bucket.

```

./self-upgrade.sh --s3  {s3-path-of-lms-release} 
                  --war {lms|rating|api-gw|frontend|auth|
                         messaging-worker|MtsSdpSolutionApi|
                         sms-broker|charging-worker} 
                  [--tenant {MTN_NG|MTN_CI|AIRTEL_NG|LAB_NETANYA}]
```

Examples:


```
./self-upgrade.sh --s3 lms-releases/J2/OD/L15.00.00 --war lms
./self-upgrade.sh --s3 lms-releases/J2/OD/L15.00.00 --war api-gw
./self-upgrade.sh --s3 lms-releases/J2/OD/L15.00.00 --war rating
./self-upgrade.sh --s3 lms-releases/J2/OD/L15.00.00 --war auth

```

For tenant specific services (workers and brokers) the tenant name should be provided. 

Examples:


```
./self-upgrade.sh --s3 lms-releases/J2/OD/L15.00.00 --war MtsSdpSolutionApi --tenant MTN_NG
./self-upgrade.sh --s3 lms-releases/J2/OD/L15.00.00 --war messaging-worker --tenant MTN_CI
./self-upgrade.sh --s3 lms-releases/J2/OD/L15.00.00 --war charging-worker --tenant AIRTEL_NG
```


## FS Structure

The project has 2 shared folders used during execution:
1. backups folder is used to backup the current war before upgrading. It will also be used for rollbacks.
2. workspace folder is temporary

The {TS} and {PID} used to uniquely identify this exact process. The TS-PID will be used as an index for remote logging.

Example:

# project home
/opt/self-upgrade/

# folders
/opt/self-upgrade/backups/${TS}-${pid}
/opt/self-upgrade/workspace/${TS}-${pid}



