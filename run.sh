#!/bin/bash

# We use the autobuild to always test our new functionality. But YOU should not do that!
# Instead use the latest tagged version as the next row
# DOCKER_CONTAINER=sitespeedio/sitespeed.io:10.1.0

DOCKER_CONTAINER=sitespeedio/sitespeed.io-autobuild:latest
DOCKER_SETUP="--cap-add=NET_ADMIN  --shm-size=4g --rm -v /config:/config -v "$(pwd)":/sitespeed.io -v /etc/localtime:/etc/localtime:ro -e MAX_OLD_SPACE_SIZE=3072 "
CONFIG="--config /sitespeed.io/config"
BROWSERS=(chrome firefox)

# We loop through all directories we have
# We run many tests to verify the functionality of sitespeed.io and you can simplify this by
# removing things you don't need!

for url in tests/$TEST/desktop/urls/*.txt ; do
    [ -e "$url" ] || continue
    for browser in "${BROWSERS[@]}" ; do
        POTENTIAL_CONFIG="./config/$(basename ${url%%.*}).json"
        [[ -f "$POTENTIAL_CONFIG" ]] && CONFIG_FILE="$(basename ${url%.*}).json" || CONFIG_FILE="desktopWithExtras.json"
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${url%%.*})"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/$CONFIG_FILE -b $browser $url
        control
    done
done

for script in tests/$TEST/desktop/scripts/*.js ; do
    [ -e "$script" ] || continue
    for browser in "${BROWSERS[@]}"  ; do
        POTENTIAL_CONFIG="./config/$(basename ${script%%.*}).json"
        [[ -f "$POTENTIAL_CONFIG" ]] && CONFIG_FILE="$(basename ${script%.*}).json" || CONFIG_FILE="desktop.json"
        NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${script%%.*})"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/$CONFIG_FILE --multi -b $browser --spa $script
        control
    done
done

for url in tests/$TEST/emulatedMobile/urls/*.txt ; do
    [ -e "$url" ] || continue
    POTENTIAL_CONFIG="./config/$(basename ${url%%.*}).json"
    [[ -f "$POTENTIAL_CONFIG" ]] && CONFIG_FILE="$(basename ${url%.*}).json" || CONFIG_FILE="emulatedMobile.json"
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${url%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/$CONFIG_FILE $url
    control
done

for script in tests/$TEST/emulatedMobile/scripts/*.js ; do
    [ -e "$script" ] || continue
    POTENTIAL_CONFIG="./config/$(basename ${script%%.*}).json"
    [[ -f "$POTENTIAL_CONFIG" ]] && CONFIG_FILE="$(basename ${script%.*}).json" || CONFIG_FILE="emulatedMobile.json"
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${script%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/$CONFIG_FILE --multi --spa $script
    control
done

# We run WebPageReplay just to verify that it works
for url in tests/$TEST/replay/urls/*.txt ; do
    [ -e "$url" ] || continue
    POTENTIAL_CONFIG="./config/$(basename ${url%%.*}).json"
    [[ -f "$POTENTIAL_CONFIG" ]] && CONFIG_FILE="$(basename ${url%.*}).json" || CONFIG_FILE="replay.json"
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${url%%.*})"
    docker run $DOCKER_SETUP -e REPLAY=true -e LATENCY=100 $DOCKER_CONTAINER $NAMESPACE $CONFIG/$CONFIG_FILE $url
    control
done

# We run WebPageTest runs to verify the WebPageTest functionality and dashboards
for url in tests/$TEST/webpagetest/desktop/urls/*.txt ; do
    [ -e "$url" ] || continue
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${url%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/webpagetest.json $url
    control
done

# You can also test using WebPageTest scripts
for script in tests/$TEST/webpagetest/desktop/scripts/* ; do
    [ -e "$script" ] || continue
    NAMESPACE="--graphite.namespace sitespeed_io.$(basename ${script%%.*})"
    docker run $DOCKER_SETUP $DOCKER_CONTAINER $NAMESPACE $CONFIG/webpagetest.json --plugins.remove browsertime --webpagetest.file $script https://www.example.org/
    control
done

# Remove the current container so we fetch the latest autobuild the next time
# If you run a stable version (as YOU should), you don't need to remove the container,
# instead make sure you remove all volumes (of data)
# docker volume prune -f
docker system prune --all --volumes -f
sleep 20
