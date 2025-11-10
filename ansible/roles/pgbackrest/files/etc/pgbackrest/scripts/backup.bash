#!/bin/bash
function log {
    msg=$1
    echo "`date +'%Y-%m-%d %H:%M:%S.%3N'` $$    INFO: $msg"
}

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
pgbackrest backup --type=full --stanza=main --log-level-console=info
