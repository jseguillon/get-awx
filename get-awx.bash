#!/usr/bin/env bash

# Bring up a local awk under docker-compose
# Usage:
#   wget -q -O - https://get.k8s.io | bash
# or
#   curl -fsSL https://get.k8s.io | bash
#
# Advanced options
#  Set AWX_RELEASE to choose between different versions:
#   * export AWX_RELEASE=9.0.1; wget -q -O - https://XXXX | bash

set -o errexit
set -o nounset
set -o pipefail

#TODO : deal with AWX_RELEASE
function bootstrap {
  docker run -v ${PWD}:/opt/local/ jseguillon/get-awx
}

function start_awx {
  #docker-compose down
  ln -s -f $(ls -td awx-env*/ | head -1)/docker-compose.yml .
  docker-compose up -d
}

bootstrap && start_awx

echo "Started 👍"

docker-compose ps
