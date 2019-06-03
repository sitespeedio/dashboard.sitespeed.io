#!/bin/bash
LOGFILE=/tmp/sitespeed.io.log
exec > $LOGFILE 2>&1
CONTROL_FILE="./sitespeed.run"
SERVER=$1

# The first parameter is the server name, so we can find the right tests to run
if [ -z "$1" ] 
then
    echo "Missing server input! You need to run with a parameter that gives the path to the configuration "
    exit 1
fi

# In your curent dir we will place a file called sitespeed.run that shows that the tests are running
# If you want to stop the tests gracefully, remove that file: rm sitespeed.io and wait for 
# the tests to finish (tail -f /tmp/sitespeed.io)

# You cannot start multiple instances!
if [ -f "$CONTROL_FILE" ]
then
  echo "$CONTROL_FILE exist, do you have running tests?"
  exit 1;
else
  touch $CONTROL_FILE
fi

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

# We use the autobuild to always test our new functionality. But YOU should not do that!
# Instead use the latest tagged version as the next row
# DOCKER_CONTAINER=sitespeedio/sitespeed.io:9.2.1

DOCKER_CONTAINER=sitespeedio/sitespeed.io-autobuild:latest
DOCKER_SETUP="--cap-add=NET_ADMIN  --shm-size=2g --rm -v /config:/config -v "$(pwd)":/sitespeed.io -v /etc/localtime:/etc/localtime:ro "
CONFIG="--config /sitespeed.io/config"
BROWSERS=(chrome firefox)

# To get thottle to work (https://github.com/sitespeedio/throttle)!
sudo modprobe ifb numifbs=1

# We loop through all directories we have
# We run many tests to verify the functionality of sitespeed.io and you can simplify this by
# removing things you don't need!

while true
do
    for urls in $SERVER/desktop/urls/* ; do
      for browser in "${BROWSERS[@]}"
        do
          # Note: If you use dots in your name you need to replace them before sending to Graphite
          # GRAPHITE_NAMESPACE=${GRAPHITE_NAMESPACE//[-.]/_}
          NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
          docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/desktop.json -b $browser $urls
          control
        done
    done

    for urls in $SERVER/desktop/scripts/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/desktop.json --multi --spa $urls
        control
    done

    for urls in $SERVER/mobile/urls/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/mobile.json $urls
        control
    done

    for urls in $SERVER/mobile/scripts/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/mobile.json --multi --spa $urls
        control
    done

    # We run WebPageReplay just to verify that it works
    for urls in $SERVER/replay/urls/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $DOCKER_SETUP -e REPLAY=true -e LATENCY=100 $DOCKER_CONTAINER $NAMESPACE $CONFIG/replay.json $urls
        control
    done

    # We run WebPageTest runs to verify the WebPageTest functionality and dashboards
    for urls in $SERVER/webpagetest/urls/* ; do
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${urls%.*})"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/webpagetest.json $urls
        control
    done

    # Remove the current container so we fetch the latest autobuild the next time
    # If you run a stable version (as YOU should), you don't need to remove the container
    docker system prune --all --volumes -f
    sleep 20
done

