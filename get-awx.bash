#!/usr/bin/env bash
# Bring up a local awk under docker-compose
# Usage:
#   wget -q -O - https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
# or
#   curl -fsSL https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
#
# Advanced options
#  Set AWX_RELEASE to choose between different versions:
#   * export AWX_RELEASE=9.0.1; wget -q -O - https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash

# made with 💓 from 🇫🇷
# please ⭐ if you like

set -o errexit
set -o pipefail

if [ "" == "$AWX_TARGET_DIR" ]; then
  AWX_TARGET_DIR="${PWD}"
fi
mkdir -p ${AWX_TARGET_DIR}

if [ "" == "$AWX_VERSION" ]; then
  AWX_VERSION="9.0.1"
fi

function bootstrap {
  # AWX_TARGET_DIR option
  mkdir -p ${AWX_TARGET_DIR}/config
  cat >  ${AWX_TARGET_DIR}/config/values.yml <<EOF
---
awx_web_docker_actual_image: "ansible/awx_web:$AWX_VERSION"
awx_task_docker_actual_image: "ansible/awx_task:$AWX_VERSION"

docker_compose_dir: "${AWX_TARGET_DIR}/.awx"
EOF
  docker run -v ${AWX_TARGET_DIR}/:/opt/local/ jseguillon/get-awx
}

function up_awx {
  docker-compose -f ${AWX_TARGET_DIR}/.awx/docker-compose.yml  up -d
}

# TODO : some down_awx cause of conlicts in name of containers

echo "🍪 : Bootstraping ..."; echo
# TODO bootstrap only option
bootstrap
echo -e "\n"

echo -e "⚡ : Starting"
up_awx

echo -e "🐈 : Started\n"

echo "👀 : Listing  ${AWX_TARGET_DIR}/.awx/ dir ⤵"
ls ${AWX_TARGET_DIR}/.awx/
echo -e "\n"

echo "🧠 : Launched containers ⤵ "
docker-compose -f ${AWX_TARGET_DIR}/.awx/docker-compose.yml ps
echo -e "\n"

echo "🔓 : Admin credentials ⤵"
grep -h -E "AWX_ADMIN_USER|AWX_ADMIN_PASSWORD"  /tmp/plouf/.awx/*.*
echo -e "\n"

echo "Stop wih \`docker-compose -f ${AWX_TARGET_DIR}/.awx/docker-compose.yml stop\`"
echo "Logs wih \`docker-compose -f ${AWX_TARGET_DIR}/.awx/docker-compose.yml logs\`"
echo -e "\n"
