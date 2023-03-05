#!/usr/bin/env bash

set -o nounset
set -o errexit

SSH_KEYS="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/6CW7KXHRJzpHB1dH5oioyNgfiAQEgldYtl4WKQjSWzodz0kBAmA/R3vV4S2cwt52V1FwlBtZdZCQT8ffUiB/lkawp/D0gHlYwFQCR/hI0yb8t4MktaP4YsyGrLLyQRxBQsClenzxW7v69P5Gargd4WygxdAAibbizg2V1vlIp3NRqchA0/lXh7eknHY3LMUtTc2UYkRTfKmyWpHnYZs6rPtSoL02uKrJvi9Un2kkW3mRqxtHXUlrl7gf5YexzLBUHnxLtiJTb97ZPxXHftcwscjyKmopNUSwMRqBCvUK57bM2jLL6gzxLumZ1zZZxi21/88UI9DaLXZgm5vmJT1p anton@dell500"

function add_ssh_keys() {
    AUTHORIZED_KEYS_PATH=${2:-}
    if [[ -z "${AUTHORIZED_KEYS_PATH}" ]]; then
        AUTHORIZED_KEYS_PATH="~/.ssh/authorized_keys"
    fi

    AUTHORIZED_KEYS_PATH=$(bash -c "readlink -f ${AUTHORIZED_KEYS_PATH}")

    KEYS="${1}"
    while read -r SSH_KEY_PUB; do
        if [[ $(cat "${AUTHORIZED_KEYS_PATH}" | grep "${SSH_KEY_PUB}" | wc -l) -eq 0 ]] ; then
            echo "${SSH_KEY_PUB}" >> "${AUTHORIZED_KEYS_PATH}"
        fi
    done <<< "${KEYS}"
}

# add remote ssh keys to root
if [[ ! -f ~/.ssh/authorized_keys ]] ; then
    ssh github.com -o "StrictHostKeyChecking no" || true
    touch ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi
add_ssh_keys "${SSH_KEYS}"

# generate local ssh key for root
PRIVATE_SSH_KEY_FILE="/root/.ssh/id_rsa"
if [[ ! -f "$PRIVATE_SSH_KEY_FILE" ]] ; then
    ssh-keygen -t rsa -N '' -f "$PRIVATE_SSH_KEY_FILE"
fi

# create non-privileged user
if id "user" >/dev/null 2>&1; then
    true
else
    adduser --disabled-password --gecos "" user
fi

# add all remote ssh keys from root to user
if [[ ! -f ~user/.ssh/authorized_keys ]] ; then
    su - user -c 'ssh github.com -o "StrictHostKeyChecking no" || true'
    touch ~user/.ssh/authorized_keys
    chown user. ~user/.ssh/authorized_keys
    chmod 600 ~user/.ssh/authorized_keys
fi
add_ssh_keys "$(cat ~/.ssh/authorized_keys)" ~user/.ssh/authorized_keys

PRIVATE_SSH_KEY_FILE=$(readlink -f ~user/.ssh/id_rsa)
if [[ ! -f "${PRIVATE_SSH_KEY_FILE}" ]] ; then
    su - user -c "ssh-keygen -t rsa -N '' -f ${PRIVATE_SSH_KEY_FILE}"
fi

# set up reboot on oom
cat << EOF > /etc/sysctl.d/oom_reboot.conf
# panic kernel on OOM
vm.panic_on_oom=1
# reboot after 10 sec on panic
kernel.panic=10

EOF
sysctl -p /etc/sysctl.d/oom_reboot.conf

# install
apt update
apt install -y \
    mosh \
    neovim \
    tmux \
    jq \
    ncdu \
    mtr \
    man \
    tldr \
    htop \
    time \
    bc \
    datamash \
    bash-completion

