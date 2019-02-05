#!/bin/bash
##############################################################################
# install_shellcheck.sh
# -----------
# Script to install the ShellCheck on Debian, Alpine.
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-31
# :VERSION: 0.0.2
##############################################################################

set -euo pipefail

i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }

exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}

shellcheck_is_installed() {
    if [ -x "$(which shellcheck)" ]; then
        shellcheck --version &>/dev/null
        if [ "$?" == "0" ]; then
            echo true
        else
            echo false
        fi
    else
        echo false
    fi
}

alpine_install_shellcheck() {
    apk update
    apk add --no-cache \
            curl \
            cabal \
            ghc \
            build-base
    cabal update
    cabal install ShellCheck || true
    cp -f "$HOME/.cabal/bin/shellcheck" /usr/local/bin/shellcheck
}

alpine_clear_up(){
    apk del cabal \
            ghc \
            build-base

    # rm -rf "$HOME/.cabal"
    # rm -rf "$HOME/.ghc"
}

do_alpine() {
    alpine_install_shellcheck
    alpine_clear_up
}

deb_install_shellcheck() {
    apt update
    apt install -y --no-install-recommends shellcheck
}

do_debian() {
    deb_install_shellcheck
}

choose_and_execute_installation() {
    if [ -x "$(which apk)" ]; then
        do_alpine
    elif [ -x "$(which apt)" ]; then
        do_debian
    else
        w_echo 'This script only work on Debian, Alpine'
    fi
}

check_installation_result(){
    if shellcheck_is_installed; then
        i_echo 'ShellCheck installed successfully'
        exit 0
    else
        e_echo 'ShellCheck installation failed. =/'
        exit 1
    fi
}

main() {
    exit_is_not_superuser
    i_echo "Install ShellCheck"

    if shellcheck_is_installed; then
        choose_and_execute_installation
        check_installation_result
    else
        w_echo 'ShellCheck already installed'
    fi
}

main "$@"
