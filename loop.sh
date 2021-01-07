#!/bin/bash

LOGFILE=/tmp/sitespeed.io.log
exec > $LOGFILE 2>&1

# In your curent dir we will place a file called sitespeed.run that shows that the tests are running
# If you want to stop the tests gracefully, remove that file: rm sitespeed.io and wait for
# the tests to finish (tail -f /tmp/sitespeed.io)
CONTROL_FILE="./sitespeed.run"

# You cannot start multiple instances!
if [ -f "$CONTROL_FILE" ]
then
    echo "$CONTROL_FILE exist, do you have running tests?"
    exit 1;
else
    touch $CONTROL_FILE
fi

# Help us end on demand
function control() {
    if [ -f "$CONTROL_FILE" ]
    then
        echo "$CONTROL_FILE found. Make another run ..."
    else
        echo "$CONTROL_FILE not found - stopping after cleaning up ..."
        docker system prune --all --volumes -f
        echo "Exit"
        exit 1
    fi
}

# To get throttle to work (https://github.com/sitespeedio/throttle)!
sudo modprobe ifb numifbs=1

while true
do
    ## For each iteration, we pull the latest code from git and run
    git pull
    source run.sh
    result=$?
    if [ $result -ne 0 ]; then
        echo 'Stop the loop $result'
        exit 0;
    fi
    
done
