#!/bin/bash

echo "Pushing to dockerhub repository $DOCKERHUB_DESTINATION"
docker build --pull -t $DOCKERHUB_DESTINATION -f "$DOCKERHUB_DOCKEFILE" "$NODE_NAME"
docker push $DOCKERHUB_DESTINATION
