#!/bin/bash
##############################################################################
# install_haskell_tool_stack.sh
# -----------
# Script to install the Haskell Tool Stack
# basically I just use it to install hadolint and shellcheck
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-31
# :VERSION: 0.0.5
##############################################################################

set -euo pipefail

i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }

exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}

try_install_requirements_if_needed() {
    if [ ! -x "$(which ghc)" ] || [ ! -x "$(which curl)" ]; then
        if [ -x "$(which apt)" ]; then
            apt update && apt install -y --no-install-recommends ghc curl
        elif [ -x "$(which apk)" ]; then
            apk update && apk add --no-cache ghc curl
        else
            e_echo 'You need have installed: curl, ghc'
            exit 1
        fi
    fi
}

install_stack() {
    for i in {1..3}; do
        i_echo "Installation attempt: $i"
        curl -sSL https://get.haskellstack.org/ | sh
        if [ $? == 0 ]; then break; fi
    done
}

add_in_path_env_var() {
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        if [ -f "$HOME/.bashrc" ]; then
            rc_file="$HOME/.bashrc"
        elif [ -f "$HOME/.zshrc" ]; then
            rc_file="$HOME/.zshrc"
        else
            rc_file="$HOME/.bashrc"
        fi
        echo 'export PATH=$PATH:$HOME/.local/bin' >> "$rc_file"
    fi
}

main() {
    exit_is_not_superuser
    if ! stack --version &>/dev/null; then
        i_echo 'Install Haskell Tool Stack'

        try_install_requirements_if_needed
        install_stack
        add_in_path_env_var

        if stack --version &>/dev/null; then
            i_echo 'Haskell Tool Stack installed successfully'
        else
            e_echo 'Haskell Tool Stack installation failed. =/'
        fi
    else
        w_echo 'Haskell Tool Stack already installed.'
    fi
}

main
