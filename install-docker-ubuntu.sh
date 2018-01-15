#!/usr/bin/env bash

set -o nounset
set -o errexit

apt-get install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get install -y docker-ce=17.12.0~ce-0~ubuntu

apt-mark hold docker-ce

usermod -aG docker user

curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

