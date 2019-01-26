#!/bin/bash -x
##############################################################################
# install_arc_openbox_theme.sh
# -----------
# Script to install the openbox theme Arc
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-26
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
URL_ARC_OPENBOX='https://github.com/dglava/arc-openbox.git'
DIRS='Arc Arc-Dark Arc-Darker'
TMP_DIR="/tmp/arc-openbox-$(date +%s)"

try_install_requeriments_if_needed() {
    if [ -z "$(which git)" ]; then
        if [ -x "$(which apt)" ]; then
            apt update
            apt install -y git
        else
            e_echo 'You need to install: git'
        fi
    fi
}

install_theme() {
    mkdir -p "$TMP_DIR" && cd "$TMP_DIR"
    git clone "$URL_ARC_OPENBOX" "$TMP_DIR"
    for dir in $DIRS; do
        mkdir -p "/usr/share/themes/$dir" || true
        cp -r "$TMP_DIR/$dir/openbox-3" "/usr/share/themes/$dir"
    done
}

main() {
    i_echo "Install Arc Openbox Theme"

    exit_is_not_superuser
    try_install_requeriments_if_needed
    install_theme

    i_echo "Arc Openbox Theme installed successfully"
}

main
