#!/bin/bash
##############################################################################
# install_playerctl.sh
# -----------
# Script to install on Debian the playerctl which allows control
# the media players through multimedia keyboard
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-24
# :VERSION: 0.0.1
##############################################################################

set -euo pipefail
i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }
exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}

# VARIABLES
URL_PLAYERCTL_DEB='https://github.com/acrisci/playerctl/releases/download/v2.0.1/playerctl-2.0.1_amd64.deb'
TMP_DIR="/tmp/playerctl-$(date +%s)"

install_requirements() {
    if [ -x "$(which wget)" ]; then
        apt update
        apt install -y wget
    fi
}

install_playerctl() {
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"
    wget "$URL_PLAYERCTL_DEB"
    dpkg -i playerctl*.deb
    rm -rf "$TMP_DIR"
}

exit_is_not_superuser
i_echo 'Install Playerctl'
install_requirements
install_playerctl
i_echo 'Playerctl installed successfully'

