#!/usr/bin/env bash

set -euo pipefail

USERNAME=${1:-user}

SSH_KEYS="${SSH_KEYS:-}"

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
if [ "${SSH_KEYS}" != "" ]; then
    add_ssh_keys "${SSH_KEYS}"
fi

# generate local ssh key for root
PRIVATE_SSH_KEY_FILE="/root/.ssh/id_rsa"
if [[ ! -f "$PRIVATE_SSH_KEY_FILE" ]] ; then
    ssh-keygen -t rsa -N '' -f "$PRIVATE_SSH_KEY_FILE"
fi

# create non-privileged user
if id "${USERNAME}" >/dev/null 2>&1; then
    true
else
    adduser --disabled-password --gecos "" ${USERNAME}
fi

# add all remote ssh keys from root to ${USERNAME}
if [[ ! -f ~${USERNAME}/.ssh/authorized_keys ]] ; then
    su - ${USERNAME} -c 'ssh github.com -o "StrictHostKeyChecking no" || true'
    bash -c "touch ~${USERNAME}/.ssh/authorized_keys && \
    chown ${USERNAME}. ~${USERNAME}/.ssh/authorized_keys && \
    chmod 600 ~${USERNAME}/.ssh/authorized_keys"
fi
add_ssh_keys "$(cat ~/.ssh/authorized_keys)" ~${USERNAME}/.ssh/authorized_keys

PRIVATE_SSH_KEY_FILE="$(eval echo ~${USERNAME})/.ssh/id_rsa"
if [[ ! -f "${PRIVATE_SSH_KEY_FILE}" ]] ; then
    su - ${USERNAME} -c "ssh-keygen -t rsa -N '' -f ${PRIVATE_SSH_KEY_FILE}"
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
    pv \
    datamash \
    bash-completion

