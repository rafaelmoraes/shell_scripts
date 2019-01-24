#!/bin/bash
##############################################################################
# install_or_update_youtube_dl.sh
# -----------
# Script to install or update the youtube-dl
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-22
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
URL_YOUTUBE_DL='https://yt-dl.org/downloads/latest/youtube-dl'

install_or_update() {
    if [ -x "$(which curl)" ]; then
        curl -L "$URL_YOUTUBE_DL" -o /usr/local/bin/youtube-dl
    else
        wget "$URL_YOUTUBE_DL" -O /usr/local/bin/youtube-dl
    fi
    chmod a+rx /usr/local/bin/youtube-dl
}

exit_is_not_superuser
i_echo 'Install or Update youtube-dl'
install_or_update
i_echo 'youtube-dl installed or updated successfully'
