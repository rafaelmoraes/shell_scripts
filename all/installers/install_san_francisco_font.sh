#!/bin/bash
##############################################################################
# install_san_francisco_font.sh
# -----------
# Script to install the font San Francisco
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-24
# :VERSION: 0.0.1
##############################################################################
set -euo pipefail # Configure bash unofficial strict mode
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
URL_SAN_FRANCISCO_FONT='https://github.com/supermarin/YosemiteSanFranciscoFont/archive/master.zip'
USER_NAME=${SUDO_USER:-$USER}
TMP_DIR="/tmp/font_san_francisco-$(date +%s)"
HELP_MESSAGE="Usage: ./install_san_francisco_font.sh [OPTIONS]

Parameters list
  -u, --user=   Set which user is owner of the installation
  -h, --help    Show usage"

set_user_home(){
   if [ "$USER_NAME" == 'root' ]; then
       USER_HOME='/root'
   else
       USER_HOME="/home/$USER_NAME"
   fi
}

try_install_requirements_if_necessary(){
    if [[ ! -x $(which wget) || ! -x $(which unzip) ]]; then
        if [[ -x $(which apt) ]]; then
            exit_is_not_superuser
            apt update
            apt install -y wget \
                           unzip
        else
            e_echo 'You need to have installed wget.'
        fi
    fi
}

install_font() {
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"
    if [ -e master.zip ]; then rm -f master.zip; fi
    wget "$URL_SAN_FRANCISCO_FONT"
    unzip master.zip
    dir_fonts_path="$USER_HOME/.local/share/fonts"
    if [ ! -e "$dir_fonts_path" ]; then mkdir -p "$dir_fonts_path"; fi
    cp ./YosemiteSanFranciscoFont-master/*.ttf "$dir_fonts_path"
    cd .. && rm -rf "$TMP_DIR"
}

set_right_owner() {
    if [ "$USER_NAME" != "$USER" ]; then
        chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"
    fi
}

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

main() {
    apply_options "$@"
    i_echo 'Install font San Francisco'
    set_user_home
    try_install_requirements_if_necessary
    install_font
    set_right_owner
    i_echo 'Font San Francisco installed successfully'
}

main "$@"
