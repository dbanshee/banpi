#! /bin/bash

SERVICE="sshd"
SERVICE_CMD="service ssh start"

if pgrep -x "$SERVICE" >/dev/null
then
    #echo "$SERVICE is running"
    :
else
    echo "$SERVICE stopped"
    echo "Respawing $SERVICE ..."
    eval $SERVICE_CMD

    MSG="$SERVICE is down. Respawing service"
    logger -p local0.notice -t ${0##*/}[$$] $MSG
    echo "$MSG" | mail -s "sshRespawn" pi@banpi
fi

