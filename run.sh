#!/bin/bash

# We use the autobuild to always test our new functionality. But YOU should not do that!
# Instead use the latest tagged version as the next row
# DOCKER_CONTAINER=sitespeedio/sitespeed.io:25.5.1

DOCKER_CONTAINER=sitespeedio/sitespeed.io-autobuild:main
DOCKER_SETUP="--cap-add=NET_ADMIN  --shm-size=4g --rm -v /config:/config -v "$(pwd)":/sitespeed.io -v /etc/localtime:/etc/localtime:ro -e MAX_OLD_SPACE_SIZE=3072 "
DESKTOP_BROWSERS_DOCKER=(chrome firefox)
DESKTOP_BROWSERS=(chrome firefox edge)
EMULATED_MOBILE_BROWSERS=(chrome)

# We loop through the desktop directory

for file in tests/docker/desktop/*.{txt,js} ; do
    for browser in "${DESKTOP_BROWSERS_DOCKER[@]}" ; do
        FILENAME=$(basename -- "$file")
        FILENAME_WITHOUT_EXTENSION="${FILENAME%.*}"
        CONFIG_FILE="config/$FILENAME_WITHOUT_EXTENSION.json"
        [[ -f "$CONFIG_FILE" ]] && echo "Using config file $CONFIG_FILE" || echo "Missing config file $CONFIG_FILE"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER --config $CONFIG_FILE -b $browser $file
        control
    done
done

for file in tests/docker/emulatedMobile/*.{txt,js} ; do
    for browser in "${EMULATED_MOBILE_BROWSERS[@]}" ; do
        FILENAME=$(basename -- "$file")
        FILENAME_WITHOUT_EXTENSION="${FILENAME%.*}"
        CONFIG_FILE="config/$FILENAME_WITHOUT_EXTENSION.json"
        [[ -f "$CONFIG_FILE" ]] && echo "Using config file $CONFIG_FILE" || echo "Missing config file $CONFIG_FILE"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER --config $CONFIG_FILE -b $browser $file
        control
    done
done

# Run test direct on Ubuntu
for file in tests/desktop/*.{txt,js} ; do
    for browser in "${DESKTOP_BROWSERS[@]}" ; do
        FILENAME=$(basename -- "$file")
        FILENAME_WITHOUT_EXTENSION="${FILENAME%.*}"
        CONFIG_FILE="config/$FILENAME_WITHOUT_EXTENSION.json"
        [[ -f "$CONFIG_FILE" ]] && echo "Using config file $CONFIG_FILE" || echo "Missing config file $CONFIG_FILE"
        sitespeed.io --config $CONFIG_FILE -b $browser $file
        control
    done
done

# Run a couple of tests using WebPageReplay
for file in tests/docker/webpagereplay/*.txt ; do
    for browser in "${DESKTOP_BROWSERS_DOCKER[@]}" ; do
        FILENAME=$(basename -- "$file")
        FILENAME_WITHOUT_EXTENSION="${FILENAME%.*}"
        CONFIG_FILE="config/$FILENAME_WITHOUT_EXTENSION.json"
        [[ -f "$CONFIG_FILE" ]] && echo "Using config file $CONFIG_FILE" || echo "Missing config file $CONFIG_FILE"
        docker run $DOCKER_SETUP  -e REPLAY=true -e LATENCY=100 $DOCKER_CONTAINER --config $CONFIG_FILE -b $browser $file
        control
    done
done

# Remove the current container so we fetch the latest autobuild the next time
# If you run a stable version (as YOU should), you don't need to remove the container,
# instead make sure you remove all volumes (of data)
# docker volume prune -f
docker system prune --all --volumes -f
sleep 20
