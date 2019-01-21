#!/bin/bash
##############################################################################
# install_google_chrome.sh
# -----------
# Script to install Google Chrome on Debian
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-21
# :VERSION: 0.0.1
##############################################################################
set -euo pipefail # Configure bash unofficial strict mode
i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }
exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo." ; exit 1; fi }
backup_file() {
    if [ $# -eq 0 ]; then e_echo "Backup failed, you need to give a file path."; exit 1; fi
    if [ ! -e "$1" ]; then e_echo "Backup failed, file not found: $1"; exit 1; fi
    suffix="-BACKUP-$(date +%Y-%m-%d--%H-%M-%S)"
    if [ $# -eq 2 ]; then DEST="$2$suffix"; else DEST="$1$suffix"; fi
    cp -r "$1" "$DEST"
}

# VARIABLES
URL_GOOGLE_CHROME='deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main'
SOURCE_FILE='/etc/apt/sources.list.d/google-chrome.list'
HELP_MESSAGE="Usage: ./install_google_chrome.sh [OPTIONS]

Parameters list
  -u, --url=    Sets the URL to download (default: $URL_GOOGLE_CHROME)
  -h, --help    Show usage"

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u) URL_GOOGLE_CHROME="$2"; shift 2;;
            --url=*) URL_GOOGLE_CHROME="${1#*=}"; shift 1;;
            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            -*) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

delete_old_source_file_if_exist() {
    if [ -e "$SOURCE_FILE" ]; then rm -f $SOURCE_FILE; fi
}

install_requirements() {
    apt update && apt install -y dirmngr wget
}

add_repository() {
    echo "$URL_GOOGLE_CHROME" > $SOURCE_FILE
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
}

install() {
    apt update && apt install -y google-chrome-stable
}

main() {
    apply_options "$@"
    exit_is_not_superuser

    i_echo "Install Google Chrome Stable"
    delete_old_source_file_if_exist
    install_requirements
    add_repository
    install
    i_echo 'Google Chrome installed successfully'
}

main "$@"
