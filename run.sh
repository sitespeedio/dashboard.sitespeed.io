#!/bin/bash

# We use the autobuild to always test our new functionality. But YOU should not do that!
# Instead use the latest tagged version as the next row
# DOCKER_CONTAINER=sitespeedio/sitespeed.io:9.2.1

DOCKER_CONTAINER=sitespeedio/sitespeed.io-autobuild:latest
DOCKER_SETUP="--cap-add=NET_ADMIN  --shm-size=2g --rm --env-file /config/env -v /config:/config -v "$(pwd)":/sitespeed.io -v /etc/localtime:/etc/localtime:ro -e MAX_OLD_SPACE_SIZE=3072 "
CONFIG="--config /sitespeed.io/config"
BROWSERS=(chrome firefox)

# We loop through all directories we have
# We run many tests to verify the functionality of sitespeed.io and you can simplify this by
# removing things you don't need!

for url in $SERVER/desktop/urls/*.txt ; do
  [ -e "$url" ] || continue
  for browser in "${BROWSERS[@]}"
    do
      # Note: If you use dots in your name you need to replace them before sending to Graphite
      # GRAPHITE_NAMESPACE=${GRAPHITE_NAMESPACE//[-.]/_}
      NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${url%%.*})"
      docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/desktop.json -b $browser $url
      control
    done
done

for script in $SERVER/desktop/scripts/*.js ; do
    [ -e "$script" ] || continue
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${script%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/desktop.json --multi --spa $script
    control
done

for url in $SERVER/emulatedMobile/urls/*.txt ; do
    [ -e "$url" ] || continue
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${url%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/emulatedMobile.json $url
    control
done

for script in $SERVER/emulatedMobile/scripts/*.js ; do
    [ -e "$script" ] || continue
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${script%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/emulatedMobile.json --multi --spa $script
    control
done

# We run WebPageReplay just to verify that it works
for url in $SERVER/replay/urls/*.txt ; do
    [ -e "$url" ] || continue
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${url%%.*})"
    docker run $DOCKER_SETUP -e REPLAY=true -e LATENCY=100 $DOCKER_CONTAINER $NAMESPACE $CONFIG/replay.json $url
    control
done

# We run WebPageTest runs to verify the WebPageTest functionality and dashboards
for url in $SERVER/webpagetest/desktop/urls/*.txt ; do
    [ -e "$url" ] || continue
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${url%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/webpagetest.json $url
    control
done

# You can also test using WebPageTest scripts
for script in $SERVER/webpagetest/desktop/scripts/* ; do
    [ -e "$script" ] || continue
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${script%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/webpagetest.json --plugins.remove browsertime --webpagetest.file $script https://www.example.org/
    control
done

# Remove the current container so we fetch the latest autobuild the next time
# If you run a stable version (as YOU should), you don't need to remove the container
docker system prune --all --volumes -f
sleep 20
