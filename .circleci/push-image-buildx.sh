#!/bin/bash

echo "Pushing to dockerhub repository $DOCKERHUB_DESTINATION"
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 --push -f "$DOCKERHUB_DOCKEFILE" -t $DOCKERHUB_DESTINATION -t ghcr.io/$DOCKERHUB_DESTINATION "$NODE_NAME"