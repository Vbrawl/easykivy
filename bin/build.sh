#!/usr/bin/bash

$EASYKIVY_DIRECTORY/bin/sync.sh
docker start -ai $CONTAINER_NAME
mkdir bin
docker cp $CONTAINER_NAME:/project/bin/app.apk ./bin/${CONTAINER_NAME}.apk
