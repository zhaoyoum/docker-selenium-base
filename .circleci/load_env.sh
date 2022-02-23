#!/bin/sh

echo '
export IMAGE=standalone-chrome
export REGISTRY=superdxp
export DOCKERHUB_PASS=fc455933-8e1f-4dca-9306-4e9f66ce099e
export DOCKERHUB_USER=superdxp
export VERSION=1.0.0
export TAG=develop
export IMAGE_ID="${REGISTRY}/${IMAGE}:${VERSION}-${TAG}"
export DIR=`pwd`
export QEMU_VERSION="v4.0.0"
' >>$BASH_ENV

. $BASH_ENV
