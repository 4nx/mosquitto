#!/bin/sh

test -t 0
if [ $? -eq 1 ]; then
    echo "Please start the mosquitto contrainer with pseudo-TTY using the -t option or 'tty: true' with docker compose"
    exit 1
fi

MOSQUITTO_UID=$(id -u mosquitto)
MOSQUITTO_GID=$(id -g mosquitto)
NEW_USER_ID=${USER_ID:-100}
NEW_GROUP_ID=${GROUP_ID:-101}

echo "Starting with mosquitto user id: ${NEW_USER_ID} and group id: ${NEW_GROUP_ID}"

if [[ ${NEW_USER_ID} -ne ${MOSQUITTO_UID} || ${NEW_GROUP_ID} -ne ${MOSQUITTO_GID} ]]; then
    echo "Change group id of mosquitto to id ${NEW_GROUP_ID}"
    groupmod -g ${NEW_GROUP_ID} mosquitto
    echo "Change user id mosquitto to id ${NEW_USER_ID}"
    usermod -u ${NEW_USER_ID} --gid ${NEW_GROUP_ID} mosquitto
fi

exec "$@"
