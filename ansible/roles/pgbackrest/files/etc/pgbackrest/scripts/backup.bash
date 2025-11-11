#!/bin/bash
ME=$(basename "$0")

function log {
    level=$1
    msg=$2
    echo "`date +'%Y-%m-%d %H:%M:%S.%3N'` $$    INFO: $msg"
}

FULL_BACKUP_KEYWORD="full"
DIFF_BACKUP_KEYWORD="diff"
DEFAULT_BACKUP_TYPE=$FULL_BACKUP_KEYWORD
type=$DEFAULT_BACKUP_TYPE
while getopts ":t:h" opt;
do
    case $opt in
    t)
        type="$OPTARG"
        if [[ $type != $DIFF_BACKUP_KEYWORD ]] && [[ $type != $FULL_BACKUP_KEYWORD ]];
        then
            echo "error: invalid argument: try '$ME -h' for more information"
            exit 1 
        fi
        ;;
    h)
        echo "usage: $ME [-t full|diff]"
        exit 0
        ;;
    *)
        echo "error: invalid option: try '$ME -h' for more information"
        exit 1
        ;;
    esac
done

leader_host=$(/opt/venv/patroni/bin/patronictl -c /etc/patroni/patroni.yml list -f json | jq -r '.[] | select(.Role == "Leader") | .Host')
if [[ "$leader_host" != "$HOSTNAME" ]];
then
    log "I'm a replica, I can't do anything, goodbye!"
    exit 0
fi
if [[ -z "$(ls -A /var/lib/pgbackrest)" ]];
then
    pgbackrest stanza-create --stanza=main --log-level-console=info
fi
pgbackrest backup --type=$type --stanza=main --log-level-console=info
