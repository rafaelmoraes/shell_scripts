#!/bin/bash
##############################################################################
# install_virtualbox.sh
# -----------------------
# Script to install the VirtualBox on Debian
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-21
# :VERSION: 0.0.1
##############################################################################
export DEBIAN_FRONTEND=noninteractive
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
URL_VIRTUALBOX='deb http://download.virtualbox.org/virtualbox/debian stretch contrib'
SOURCE_FILE='/etc/apt/sources.list.d/virtualbox.list'
HELP_MESSAGE="Usage: ./install_virtualbox.sh [OPTIONS]

Parameters list
  -u, --url=    Sets the URL to download (default: $URL_VIRTUALBOX)
  -h, --help    Show usage"

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u) URL_VIRTUALBOX="$2"; shift 2;;
            --url=*) URL_VIRTUALBOX="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

delete_old_source_file_if_exist() {
    if [ -e "$SOURCE_FILE" ]; then rm -f "$SOURCE_FILE"; fi
}

add_repository() {
    echo "$URL_VIRTUALBOX" | tee "$SOURCE_FILE"
    rm -f oracle_vbox_2016 || true
    wget https://www.virtualbox.org/download/oracle_vbox_2016.asc
    apt-key add oracle_vbox_2016.asc
    rm -f oracle_vbox_2016
}

install_requirements() {
    apt update && apt install -y dirmngr wget
}

install() {
    apt update && apt install -y virtualbox-5.2
}

main() {
    apply_options "$@"
    exit_is_not_superuser

    i_echo "Install VirtualBox 5.2"
    delete_old_source_file_if_exist
    install_requirements
    add_repository
    install
    i_echo "VirtualBox installed successfully"
}

main "$@"
