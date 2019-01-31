#!/bin/bash
##############################################################################
# install_haskell_tool_stack.sh
# -----------
# Script to install the Haskell Tool Stack on Alpine Linux,
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

install_requirements() {
    apk update
    apk upgrade
    apk add --no-cache \
        ghc \
        curl
}

install_stack() {
    curl -sSL https://get.haskellstack.org/ | sh
}

add_in_path_env_var() {
    echo 'export PATH=$PATH:$HOME/.local/bin' >> "$HOME/.bashrc"
}

main() {
    exit_is_not_superuser
    i_echo 'Install Haskell Tool Stack'

    install_requirements
    install_stack
    add_in_path_env_var

    i_echo 'Haskell Tool Stack installed successfully'
}

main "$@"
