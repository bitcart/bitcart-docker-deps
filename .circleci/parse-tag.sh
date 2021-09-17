#!/bin/bash

SEPARATOR=$(expr index "$CIRCLE_TAG" "/")
NODE_NAME=${CIRCLE_TAG:0:$SEPARATOR-1}
REVISION=""
NODE_VERSION="${CIRCLE_TAG:$SEPARATOR}"
if expr index "$NODE_VERSION" "-" >/dev/null; then
    SEPARATOR_REVISION=$(expr index "$NODE_VERSION" "-")
    REVISION="${NODE_VERSION:$SEPARATOR_REVISION}"
    NODE_VERSION="${NODE_VERSION:$SEPARATOR:$SEPARATOR_REVISION-$SEPARATOR-1}"
fi
LATEST_TAG="${CIRCLE_TAG:$SEPARATOR}"
DOCKERHUB_REPO="bitcartcc/$NODE_NAME"
DOCKERHUB_REPO="${DOCKERHUB_REPO,,}"
DOCKERHUB_DESTINATION="$DOCKERHUB_REPO:$LATEST_TAG"
DOCKERHUB_DOCKEFILE_ARM64="$NODE_NAME/linuxarm64v8.Dockerfile"
DOCKERHUB_DOCKEFILE_ARM32="$NODE_NAME/linuxarm32v7.Dockerfile"
DOCKERHUB_DOCKEFILE_AMD64="$NODE_NAME/linuxamd64.Dockerfile"

echo "LATEST_TAG=$LATEST_TAG"
echo "NODE_VERSION=$NODE_VERSION"
echo "REVISION=$REVISION"
echo "DOCKERHUB_REPO=$DOCKERHUB_REPO"
echo "DOCKERHUB_DESTINATION=$DOCKERHUB_DESTINATION"
echo "DOCKERHUB_DOCKEFILE_AMD64=$DOCKERHUB_DOCKEFILE_AMD64"
echo "DOCKERHUB_DOCKEFILE_ARM32=$DOCKERHUB_DOCKEFILE_ARM32"
echo "DOCKERHUB_DOCKEFILE_ARM64=$DOCKERHUB_DOCKEFILE_ARM64"
