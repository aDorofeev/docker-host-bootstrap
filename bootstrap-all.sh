#!/usr/bin/env bash

set -o nounset
set -o errexit

SCRIPT_PATH=$(readlink -f $0)
SCRIPT_DIR=$(dirname ${SCRIPT_PATH})

HOSTNAME="${1:-}"
if [ ! "$HOSTNAME" = "" ]; then
    ${SCRIPT_DIR}/hostname-set.sh "${HOSTNAME}"
fi

${SCRIPT_DIR}/bootstrap.sh
${SCRIPT_DIR}/install-docker.sh

