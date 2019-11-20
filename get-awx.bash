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

set -o errexit
set -o nounset
set -o pipefail

# TODO arg test and default
AWX_TARGET_DIR=${PWD}
mkdir -p ${AWX_TARGET_DIR}
#TODO : deal with AWX_RELEASE
#FIXME : prefer creating target dir here => send with env => env used to override dest for mount points

function bootstrap {
  # TODO : test target exist here + add AWX_TARGET_DIR option
  mkdir -p ${AWX_TARGET_DIR}/config

  # TODO : local value file instead dumping default
  cat > config/values.yml <<EOF
---
awx_web_docker_actual_image: "ansible/awx_web:9.0.1"
awx_task_docker_actual_image: "ansible/awx_task:9.0.1"

# Common Docker parameters
awx_task_hostname: awx
awx_web_hostname: awxweb
postgres_data_dir: "${PWD}/.awx/pgdocker"
host_port: 80
host_port_ssl: 443
#ssl_certificate:
docker_compose_dir: "${PWD}/.awx"
# This will create or update a default admin (superuser) account in AWX, if not provided
# then these default values are used
admin_user: admin
admin_password: password

pg_username: awx
pg_password: awxpass
pg_database: awx
pg_port: 5432
#pg_sslmode: require


# RabbitMQ Configuration
rabbitmq_password: awxpass
rabbitmq_erlang_cookie: cookiemonster

# AWX Secret key
# It's *very* important that this stay the same between upgrades or you will lose the ability to decrypt
# your credentials
secret_key: awxsecret

# Advanced config
dockerhub_version: "9.0.1"

rabbitmq_version: "3.7.4"
rabbitmq_image: "ansible/awx_rabbitmq:{{rabbitmq_version}}"
rabbitmq_default_vhost: "awx"
rabbitmq_erlang_cookie: "cookiemonster"
rabbitmq_host: "rabbitmq"
rabbitmq_port: "5672"
rabbitmq_user: "guest"
rabbitmq_password: "guest"

postgresql_version: "10"
postgresql_image: "postgres:{{postgresql_version}}"


memcached_image: "memcached"
memcached_version: "alpine"
memcached_host: "memcached"
memcached_port: "11211"
EOF
  docker run -e "LOCAL_DEST_DIR=${AWX_TARGET_DIR}/.awx" -v ${AWX_TARGET_DIR}:/opt/local/ jseguillon/get-awx
}

function up_awx {
  docker-compose -f ${AWX_TARGET_DIR}/.awx/docker-compose.yml  up -d
}

# TODO : some down_awx cause of conlicts in name of containers


echo "🍪 : Bootstraping ..."; echo
# TODO bootstrap only
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

# made with 💓 from 🇫🇷
# ⭐ if you like 👍
