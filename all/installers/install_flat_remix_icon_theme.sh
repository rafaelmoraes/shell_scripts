#!/bin/bash
##############################################################################
# install_flat_remix_icon_theme.sh
# -----------
# Script to install and configure Flat Remix GTK theme
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
backup_file() {
    if [ $# -eq 0 ]; then e_echo "Backup failed, you need to give a file path."; exit 1; fi
    if [ ! -e "$1" ]; then e_echo "Backup failed, file not found: $1"; exit 1; fi
    suffix="-BACKUP-$(date +%Y-%m-%d--%H-%M-%S)"
    if [ $# -eq 2 ]; then dest="$2$suffix"; else dest="$1$suffix"; fi
    cp -r "$1" "$dest"
}

# VARIABLES
URL_ICON_THEME='https://github.com/daniruiz/flat-remix'
USER_NAME=${SUDO_USER:-$USER}
HELP_MESSAGE="Usage: ./install_flat_remix_icon_theme.sh [OPTIONS]

Parameters list
  -u, --user=   Defines which user is the owner of the installation
  -h, --help    Show usage"

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u) USER_NAME="$2"; shift 2;;
            --user=*) USER_NAME="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

set_user_home() {
    if [ "$USER_NAME" == 'root' ]; then
        USER_HOME='/root'
    else
        USER_HOME="/home/$USER_NAME"
    fi
}

install_requirements() {
    if [ -z "$(which git)" ]; then
        if [ ! -z "$(which apt)" ]; then
            exit_is_not_superuser
            apt update
            apt install -y git
        else
            w_echo 'You need to install git first.'
            exit 1
        fi
    fi
}

install_icon_theme() {
    rm -rf /tmp/flat-remix || true
    git clone $URL_ICON_THEME /tmp/flat-remix
    mkdir -p "$USER_HOME/.icons" || true
    cp -r /tmp/flat-remix/Flat-Remix* "$USER_HOME/.icons"
    if [ -x gsettings ]; then
        gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix"
    fi
    rm -rf /tmp/flat-remix
}

set_right_owner() {
    if [ "$USER_NAME" != "$USER" ]; then
        chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"
    fi
}

main() {
    apply_options "$@"

    i_echo 'Install Flat Remix icon theme'
    set_user_home
    install_requirements
    install_icon_theme
    set_right_owner
    i_echo 'Flat Remix icon theme installed successfully'
}

main "$@"
