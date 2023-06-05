#!/usr/bin/env bash

set -o nounset
set -o errexit

SCRIPT_PATH=$(readlink -f $0)
SCRIPT_DIR=$(dirname ${SCRIPT_PATH})

USERNAME="${1:-user}"
HOSTNAME="${2:-}"
if [ ! "$HOSTNAME" = "" ]; then
    ${SCRIPT_DIR}/hostname-set.sh "${HOSTNAME}"
fi

${SCRIPT_DIR}/bootstrap.sh "${USERNAME}"
${SCRIPT_DIR}/install-docker.sh "${USERNAME}"

