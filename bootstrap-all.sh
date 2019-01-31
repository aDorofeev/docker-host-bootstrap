#!/usr/bin/env bash

set -o nounset
set -o errexit

SCRIPT_PATH=$(readlink -f $0)
SCRIPT_DIR=$(dirname ${SCRIPT_PATH})

HOSTNAME="${1}"

${SCRIPT_DIR}/hostname-set.sh "${HOSTNAME}"
${SCRIPT_DIR}/bootstrap.sh
${SCRIPT_DIR}/install-docker-ubuntu.sh
