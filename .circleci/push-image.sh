#!/bin/bash

echo "Pushing to dockerhub repository $DOCKERHUB_DESTINATION"
docker build --pull -t $DOCKERHUB_DESTINATION -t ghcr.io/$DOCKERHUB_DESTINATION -t harbor.nirvati.org/$DOCKERHUB_DESTINATION -f "$DOCKERHUB_DOCKEFILE" "$NODE_NAME"
docker push $DOCKERHUB_DESTINATION && docker push ghcr.io/$DOCKERHUB_DESTINATION && docker push harbor.nirvati.org/$DOCKERHUB_DESTINATION
