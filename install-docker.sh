#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

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

#curl -fsSL https://download.docker.com/linux/${OS_NAME}/gpg | apt-key add -

if [[ ! -f /etc/apt/trusted.gpg.d/docker.gpg ]]; then
    curl -fsSL https://download.docker.com/linux/${OS_NAME}/gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/docker.gpg
fi

add-apt-repository --yes \
   "deb [arch=amd64] https://download.docker.com/linux/${OS_NAME} \
   $(lsb_release -cs) \
   stable"

apt-get update

# If docker is already installed - enable live-restore prior to updating it
if [[ -d /etc/docker ]]; then
    echo '{
      "live-restore": true
}' > /etc/docker/daemon.json
    systemctl reload docker
fi

#LATEST_DOCKER=$(apt-cache madison docker-ce | head -n 1 | awk '{print $3}')
#apt-get install -y docker-ce="${LATEST_DOCKER}"
#apt-mark hold docker-ce

apt-get install -y docker-ce
if id -u user 2>/dev/null; then
    usermod -aG docker user
fi

COMPOSE_RELEASE_NAME="docker-compose-`uname -s  | tr '[:upper:]' '[:lower:]'`-`uname -m`"

COMPOSE_DL_URL=$(curl -f -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[]|select(.name=="'"${COMPOSE_RELEASE_NAME}"'").browser_download_url')
curl -sL ${COMPOSE_DL_URL} > /usr/local/bin/docker-compose.tmp
chmod +x /usr/local/bin/docker-compose.tmp
mv /usr/local/bin/docker-compose.tmp /usr/local/bin/docker-compose
#sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"

# Enable live restore if not yet enabled
if [[ ! -f /etc/docker/daemon.json ]]; then
    mkdir -p /etc/docker
    echo '{
      "live-restore": true
}' > /etc/docker/daemon.json
    
    systemctl reload docker
fi

