#!/bin/bash
LOGFILE=/tmp/sitespeed.io.log
exec > $LOGFILE 2>&1
CONTROL_FILE="./sitespeed.run"
SERVER=$1

if [ -z "$1" ] 
then
    echo "Missing server input! You need to run with a parameter that gives the path to the configuration "
    exit 1
fi


if [ -f "$CONTROL_FILE" ]
then
  echo "$CONTROL_FILE exist, do you have running tests?"
  exit 1;
else
  touch $CONTROL_FILE
fi

function cleanup() {
  docker system prune --all --volumes -f
}

function control() {
  if [ -f "$CONTROL_FILE" ]
  then
    echo "$CONTROL_FILE found. Make another run ..."
  else
    echo "$CONTROL_FILE not found - stopping after cleaning up ..."
    cleanup
    echo "Exit"$
    exit 1
  fi
}
# We use the autobuild to always test our new functionality. But YOU should not do that!
# Instead use the latest tagged version as the next row
# DOCKER_CONTAINER=sitespeedio/sitespeed.io:9.2.0
DOCKER_CONTAINER=sitespeedio/sitespeed.io-autobuild:latest
DOCKER_SETUP="--cap-add=NET_ADMIN  --shm-size=2g --rm -v /config:/config -v "$(pwd)":/sitespeed.io -v /etc/localtime:/etc/localtime:ro "
CONFIG="--config /sitespeed.io/$SERVER/config"
sudo modprobe ifb numifbs=1

while true
do
    for urls in $SERVER/desktop/urls/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $CABLE $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/desktop.json $urls
        control
    done

    for urls in $SERVER/desktop/scripts/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $CABLE $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/desktop.json --multi --spa $urls
        control
    done
    for urls in $SERVER/mobile/urls/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $CABLE $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/mobile.json $urls
        control
    done

    for urls in $SERVER/mobile/scripts/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $CABLE $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/mobile.json --multi --spa $urls
        control
    done

    for urls in $SERVER/replay/urls/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $CABLE $DOCKER_SETUP -e REPLAY=true -e LATENCY=100 $DOCKER_CONTAINER $NAMESPACE $CONFIG/replay.json $urls
        control
    done

    for urls in $SERVER/webpagetest/urls/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $CABLE $DOCKER_SETUP -e REPLAY=true -e LATENCY=100 $DOCKER_CONTAINER $NAMESPACE $CONFIG/webpagetest.json $urls
        control
    done

    cleanup
    sleep 20
done

