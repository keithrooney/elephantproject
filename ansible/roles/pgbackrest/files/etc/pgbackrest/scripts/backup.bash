#!/bin/bash

set -e 

ME=$(basename "$0")

function log {
    msg=$1
    echo "`date +'%Y-%m-%d %H:%M:%S.%3N'` $$    INFO: $msg"
}

FULL_BACKUP_KEYWORD="full"
INCREMENTAL_BACKUP_KEYWORD="incr"
DEFAULT_BACKUP_TYPE=$FULL_BACKUP_KEYWORD
type=$DEFAULT_BACKUP_TYPE
while getopts ":t:h" opt;
do
    case $opt in
    t)
        type="$OPTARG"
        if [[ $type != $INCREMENTAL_BACKUP_KEYWORD ]] && [[ $type != $FULL_BACKUP_KEYWORD ]];
        then
            echo "error: invalid argument: try '$ME -h' for more information"
            exit 1 
        fi
        ;;
    h)
        echo "usage: $ME [-t $FULL_BACKUP_KEYWORD|$INCREMENTAL_BACKUP_KEYWORD]"
        exit 0
        ;;
    *)
        echo "error: invalid option: try '$ME -h' for more information"
        exit 1
        ;;
    esac
done

DEFAULT_REPLICA_GOODBYE_MESSAGE="I'm a replica, I can't do anything, goodbye!"
DEFAULT_STANDBY_SIGNAL_PATH="$PGDATA/standby.signal"
DEFAULT_PATRONICTL_PATH="/opt/venv/patroni/bin/patronictl"

# If neither of none of these conditions hold true, we assume the node is the leader and proceed with backup
if [[ -f "$DEFAULT_PATRONICTL_PATH" ]];
then
    # If Patroni is being used, verify the node is not the leader through the API.
    leader_host=$(/opt/venv/patroni/bin/patronictl -c /etc/patroni/patroni.yml list -f json | jq -r '.[] | select(.Role == "Leader") | .Host')
    if [[ "$leader_host" != "$HOSTNAME" ]];
    then
        log "$DEFAULT_REPLICA_GOODBYE_MESSAGE"
        exit 0
    fi
elif [[ -f "$DEFAULT_STANDBY_SIGNAL_PATH" ]];
then
    # If streaming replication is being used, verify the node is not the leader by checking if the "standby.signal" file exists.
    log "$DEFAULT_REPLICA_GOODBYE_MESSAGE"
    exit 0
fi

if [[ -z "$(ls -A /var/lib/pgbackrest)" ]];
then
    # Create the initial stanza before the backup if it doesn't exist
    pgbackrest stanza-create --stanza=main --log-level-console=info
fi

pgbackrest backup --type=$type --stanza=main --log-level-console=info
