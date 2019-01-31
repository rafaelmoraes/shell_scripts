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
# :VERSION: 0.0.1
##############################################################################

set -euo pipefail

i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }

exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}

try_install_requirements_if_needed() {
    if [ -x "$(which ghc)" ] || [ -x "$(which curl)" ]; then
        if [ -x "$(which apt)" ]; then
            apt update && apt install -y ghc curl
        elif [ -x "$(which apk)" ]; then
            apk update $$ apk add --no-cache ghc curl
        else
            e_echo 'You need have installed: curl, ghc'
        fi
    fi
}

install_stack() {
    curl -sSL https://get.haskellstack.org/ | sh
}

add_in_path_env_var() {
    if [ -f "$HOME/.bashrc" ]; then
        rc_file="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        rc_file="$HOME/.zshrc"
    else
        rc_file="$HOME/.bashrc"
    fi
    echo 'export PATH=$PATH:$HOME/.local/bin' >> "$rc_file"
}

main() {
    exit_is_not_superuser
    i_echo 'Install Haskell Tool Stack'

    try_install_requirements_if_needed
    install_stack
    add_in_path_env_var

    i_echo 'Haskell Tool Stack installed successfully'
}

main "$@"