#!/bin/bash

SERVER=$1
while true
do
    git pull
    source run.sh $SERVER
    result=$?
    if [ $result -ne 0 ]; then
        echo 'Stop the loop' 
        exit 0;
    fi
done