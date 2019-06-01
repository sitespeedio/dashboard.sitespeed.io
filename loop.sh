#!/bin/bash
LOGFILE=/tmp/sitespeed.io.log
exec > $LOGFILE 2>&1

SERVER=$1
while true
do
    ## For each iteration, we pull the latest code from git and run
    git pull
    source run.sh $SERVER
    result=$?
    if [ $result -ne 0 ]; then
        echo 'Stop the loop' 
        exit 0;
    fi
done