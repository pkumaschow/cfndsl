#!/bin/bash
set -e

RUNTIME=docker
if [ "${1}" = "podman" ]; then
  RUNTIME=podman
fi

export CFNDSL_VERSION=1.7.3

echo "Building cfndsl version $CFNDSL_VERSION"

if [ -z ${CI} ]; then
  ${RUNTIME} build --build-arg CFNDSL_VERSION=$CFNDSL_VERSION -t cfndsl:latest -t cfndsl:$CFNDSL_VERSION .
else
  ${RUNTIME} build --build-arg CFNDSL_VERSION=$CFNDSL_VERSION -t cfndsl:latest -t cfndsl:$CFNDSL_VERSION /godata/pipelines/docker-cfndsl/.
fi
