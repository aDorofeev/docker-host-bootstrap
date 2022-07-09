#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o nounset
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
exit


curl -fsSL https://download.docker.com/linux/${OS_NAME}/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/${OS_NAME} \
   $(lsb_release -cs) \
   stable"

apt-get update

LATEST_DOCKER=$(apt-cache madison docker-ce | sort -r | head -n 1 | awk '{print $3}')

apt-get install -y docker-ce="${LATEST_DOCKER}"

apt-mark hold docker-ce

usermod -aG docker user

COMPOSE_RELEASE_NAME="docker-compose-`uname -s  | tr '[:upper:]' '[:lower:]'`-`uname -m`"

COMPOSE_DL_URL=$(curl -f -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[]|select(.name=="'"${COMPOSE_RELEASE_NAME}"'").browser_download_url')
curl -sL COMPOSE_DL_URL > /usr/local/bin/docker-compose.tmp
chmod +x /usr/local/bin/docker-compose.tmp
mv /usr/local/bin/docker-compose.tmp /usr/local/bin/docker-compose
sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"

# Enable live restore
echo '{
  "live-restore": true
}' > /etc/docker/daemon.json

systemctl reload docker

