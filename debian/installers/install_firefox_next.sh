#!/bin/bash
##############################################################################
# install_firefox_next.sh
# -----------------------
# Script to install the Firefox Next on Debian
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
exit_is_not_superuser() { if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit ; fi }
backup_file() {
    if [ $# -eq 0 ]; then e_echo "Backup failed, you need to give a file path."; exit 1; fi
    if [ ! -e "$1" ]; then e_echo "Backup failed, file not found: $1"; exit 1; fi
    suffix="-BACKUP-$(date +%Y-%m-%d--%H-%M-%S)"
    if [ $# -eq 2 ]; then DEST="$2$suffix"; else DEST="$1$suffix"; fi
    cp -r "$1" "$DEST"
}

# VARIABLES
URL_FIREFOX_NEXT='deb http://ppa.launchpad.net/mozillateam/firefox-next/ubuntu trusty main'
SOURCE_FILE='/etc/apt/sources.list.d/firefox-next.list'
HELP_MESSAGE="Usage: ./install_firefox_next [OPTIONS]

Parameters list
  -u, --url=    Sets the URL to download (default: $URL_FIREFOX_NEXT)
  -h, --help    Show usage"

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u) URL_FIREFOX_NEXT="$2"; shift 2;;
            --url=*) URL_FIREFOX_NEXT="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            -*) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

delete_old_source_file_if_exist() {
    if [ -e "$SOURCE_FILE" ]; then rm -f "$SOURCE_FILE"; fi
}

add_repository() {
    echo "$URL_FIREFOX_NEXT" | tee "$SOURCE_FILE"
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
                --recv-keys 0AB215679C571D1C8325275B9BDB3D89CE49EC21
}

install_requirements() {
    apt update && apt install -y dirmngr wget
}

install() {
    apt update && apt install -y firefox
}

main() {
    apply_options "$@"
    exit_is_not_superuser

    i_echo "Install Firefox Next"
    delete_old_source_file_if_exist
    install_requirements
    add_repository
    install
    i_echo "Firefox installed successfully"
}

main "$@"
