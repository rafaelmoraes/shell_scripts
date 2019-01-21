#!/bin/bash
##############################################################################
# install_ulauncher
# -----------------------------------
# Script to install on Debian the Ulauncher - application launcher for linux https://ulauncher.io/
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
exit_is_not_superuser() { if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi }
backup_file() {
    if [ $# -eq 0 ]; then e_echo "Backup failed, you need to give a file path."; exit 1; fi
    if [ ! -e "$1" ]; then e_echo "Backup failed, file not found: $1"; exit 1; fi
    suffix="-BACKUP-$(date +%Y-%m-%d--%H-%M-%S)"
    if [ $# -eq 2 ]; then DEST="$2$suffix"; else DEST="$1$suffix"; fi
    cp -r "$1" "$DEST"
}

# VARIABLES
DEFAULT_VERSION='4.3.1.r4'
URL_DEFAULT="https://github.com/Ulauncher/Ulauncher/releases/download/$DEFAULT_VERSION/ulauncher_${DEFAULT_VERSION}_all.deb"
ULAUNCHER_VERSION=''
URL_ULAUNCHER=''
HELP_MESSAGE="Usage: ./install_ulauncher.sh [OPTIONS]

Parameters list
  -v, --version=    Sets the version which will be install (default: $DEFAULT_VERSION)
  -u, --url=        Sets the URL to make download of the Ulauncher (default: $URL_DEFAULT)
  -h, --help        Show usage

  [ATTENTION] -u,--url has priority over -v,--version"

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -v) ULAUNCHER_VERSION="$2"; shift 2;;
            --version=*) ULAUNCHER_VERSION="${1#*=}"; shift 1;;

            -u) URL_ULAUNCHER="$2"; shift 2;;
            --url=*) URL_ULAUNCHER="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;
            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

build_url() {
    if [[ -z "$URL_ULAUNCHER" && ! -z "$ULAUNCHER_VERSION" ]]; then
        URL_ULAUNCHER=${URL_DEFAULT//$DEFAULT_VERSION/$ULAUNCHER_VERSION}
    fi
    if [ -z "$URL_ULAUNCHER" ]; then URL_ULAUNCHER=$URL_DEFAULT; fi
}

install() {
    rm -f ulauncher*.deb || true
    wget "$URL_ULAUNCHER"
    dpkg -i ulauncher*.deb || true
    rm -f ulauncher*.deb
    apt install --fix-broken -y
}

main() {
    apply_options "$@"
    exit_is_not_superuser

    i_echo "Installing Ulauncher"
    build_url
    install
    i_echo "Ulauncher installed successfully"
}

main "$@"
