#!/usr/bin/env bash

set -euo pipefail

USERNAME=${1:-user}

OS_NAME=$(cat /etc/os-release | grep -oP '(?<=^ID=).+')

if [ "${OS_NAME}" = "ubuntu" ]; then
    apt-get install -y \
         apt-transport-https \
         ca-certificates \
         curl \
         software-properties-common \
         gpg-agent
elif [ "${OS_NAME}" = "debian" ]; then
    apt-get install -y \
         apt-transport-https \
         ca-certificates \
         curl \
         gnupg2 \
         software-properties-common
else
    >&2 echo "OS not supported: ${OS_NAME}"
fi

if [[ ! -f /etc/apt/trusted.gpg.d/docker.gpg ]]; then
    curl -fsSL https://download.docker.com/linux/${OS_NAME}/gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/docker.gpg
fi

add-apt-repository --yes \
   "deb [arch=amd64] https://download.docker.com/linux/${OS_NAME} \
   $(lsb_release -cs) \
   stable"

apt-get update

# Disable live-restore if enabled, since it may cause issues
if [[ -f /etc/docker/daemon.json ]] && [[ $(cat /etc/docker/daemon.json | grep live-restore | wc -l) -eq 1 ]] ; then
    cat /etc/docker/daemon.json | jq 'del(."live-restore")' > /etc/docker/daemon.json.tmp
    if [ $(cat /etc/docker/daemon.json.tmp | grep -P '^\{\}$' | wc -l) -eq 1 ]; then
        rm -f /etc/docker/daemon.json*
        systemctl reload docker
    else
        HASH_BEFORE=$(md5sum /etc/docker/daemon.json | awk '{print $1}')
        HASH_AFTER=$(md5sum /etc/docker/daemon.json.tmp | awk '{print $1}')
        cat /etc/docker/daemon.json.tmp > /etc/docker/daemon.json
        rm -f /etc/docker/daemon.json.tmp
        if [ "${HASH_BEFORE}" != "${HASH_AFTER}" ]; then
            systemctl reload docker
        fi
    fi
fi

#LATEST_DOCKER=$(apt-cache madison docker-ce | head -n 1 | awk '{print $3}')
#apt-get install -y docker-ce="${LATEST_DOCKER}"
#apt-mark hold docker-ce

apt-get install -y docker-ce
if id -u ${USERNAME} 2>/dev/null; then
    usermod -aG docker ${USERNAME}
fi
