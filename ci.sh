#!/bin/bash
set -e

export CFNDSL_VERSION=1.3.0

echo "Building cfndsl version $CFNDSL_VERSION"

if [ -z ${CI}]; then
  docker build --build-arg CFNDSL_VERSION=$CFNDSL_VERSION -t cfndsl:latest -t cfndsl:$CFNDSL_VERSION .
else
  docker build --build-arg CFNDSL_VERSION=$CFNDSL_VERSION -t cfndsl:latest -t cfndsl:$CFNDSL_VERSION /godata/pipelines/docker-cfndsl/.
fi
