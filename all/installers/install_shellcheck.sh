#!/bin/bash
##############################################################################
# install_shellcheck.sh
# -----------
# Script to install the ShellCheck on Debian, Alpine.
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

alpine_configure_path_env_var() {
    if ! echo "$PATH" | grep -q "$HOME/.cabal/bin"; then
        if [ -f "$HOME/.bashrc" ]; then
            rc_file="$HOME/.bashrc"
        elif [ -f "$HOME/.zshrc" ]; then
            rc_file="$HOME/.zshrc"
        else
            rc_file="$HOME/.bashrc"
        fi
        new_path='export PATH=$PATH:$HOME/.cabal/bin'
        echo "$new_path" >> "$rc_file"
        source "$rc_file"
    fi
}

alpine_install_shellcheck() {
    if [ -x "$(which apk)" ]; then
        apk update
        apk add --no-cache \
                curl \
                cabal \
                ghc \
                build-base

        cabal update
        cabal install ShellCheck
        alpine_configure_path_env_var
        exit 0
    fi
}

deb_install_shellcheck() {
    if [ -x "$(which apt)" ]; then
        apt update
        apt install -y shellcheck
        exit 0
    fi
}

install_shellcheck() {
    if [ ! -x "$(which shellcheck)" ]; then
        alpine_install_shellcheck
        deb_install_shellcheck
        w_echo 'This script only work on Debian, Alpine'
    else
        w_echo 'ShellCheck already installed'
    fi
}

main() {
    exit_is_not_superuser
    i_echo "Install ShellCheck"

    install_shellcheck

    i_echo 'ShellCheck installed successfully'
}

main "$@"