#!/bin/bash

echo "Pushing to dockerhub repository $DOCKERHUB_DESTINATION"
docker login --username=$DOCKER_USER --password=$DOCKER_PASS
docker build -t $DOCKERHUB_DESTINATION "$NODE_NAME"
docker push $DOCKERHUB_DESTINATION