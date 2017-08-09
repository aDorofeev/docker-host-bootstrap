#!/usr/bin/env bash

set -o nounset
set -o errexit

SSH_KEYS="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/6CW7KXHRJzpHB1dH5oioyNgfiAQEgldYtl4WKQjSWzodz0kBAmA/R3vV4S2cwt52V1FwlBtZdZCQT8ffUiB/lkawp/D0gHlYwFQCR/hI0yb8t4MktaP4YsyGrLLyQRxBQsClenzxW7v69P5Gargd4WygxdAAibbizg2V1vlIp3NRqchA0/lXh7eknHY3LMUtTc2UYkRTfKmyWpHnYZs6rPtSoL02uKrJvi9Un2kkW3mRqxtHXUlrl7gf5YexzLBUHnxLtiJTb97ZPxXHftcwscjyKmopNUSwMRqBCvUK57bM2jLL6gzxLumZ1zZZxi21/88UI9DaLXZgm5vmJT1p anton@dell500"
if [ $(cat ~/.ssh/authorized_keys | grep "$SSH_KEYS" | wc -l) -eq 0 ] ; then
    ssh github.com -o "StrictHostKeyChecking no"
    echo "$SSH_KEYS" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi

PRIVATE_SSH_KEY_FILE="$HOME/.ssh/id_rsa"
if [ ! -f "$PRIVATE_SSH_KEY_FILE" ] ; then
    ssh-keygen -t rsa -N '' -f "$PRIVATE_SSH_KEY_FILE"
fi

# install 
apt update
apt install -y \
    vim \
    tmux \
    man \
    htop \
    bash-completion

if id "user" >/dev/null 2>&1; then
    echo "user exists"
else
    adduser --disabled-password --gecos "" user
    if [ $(cat ~user/.ssh/authorized_keys | grep "$SSH_KEYS" | wc -l) -eq 0 ] ; then
        su - user -c 'ssh github.com -o "StrictHostKeyChecking no"'
        echo "$SSH_KEYS" >> ~user/.ssh/authorized_keys
        chmod 600 ~user/.ssh/authorized_keys
        PRIVATE_SSH_KEY_FILE="~user/.ssh/id_rsa"
        if [ ! -f "$PRIVATE_SSH_KEY_FILE" ] ; then
            ssh-keygen -t rsa -N '' -f "$PRIVATE_SSH_KEY_FILE"
        fi
    fi
fi

