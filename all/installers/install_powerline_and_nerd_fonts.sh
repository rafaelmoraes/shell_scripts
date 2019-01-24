#!/bin/bash
##############################################################################
# install_powerline_and_nerd_fonts.sh
# -----------
# Script to install Powerline and Nerd fonts
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-24
# :VERSION: 0.0.2
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
    if [ $# -eq 2 ]; then DEST="$2$suffix"; else DEST="$1$suffix"; fi
    cp -r "$1" "$DEST"
}

# VARIABLES
USER_NAME=${SUDO_USER:-$USER}
URL_POWERLINE_FONT='https://github.com/powerline/fonts.git'
BASE_URL_NERD_FONT='https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts'
URL_ROBOTO_MONO_NERD_FONT="$BASE_URL_NERD_FONT/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete%20Mono.ttf"
URL_SPACE_MONO_NERD_FONT="$BASE_URL_NERD_FONT/SpaceMono/Regular/complete/Space%20Mono%20Nerd%20Font%20Complete%20Mono.ttf"
HELP_MESSAGE="Usage: .install_powerline_and_nerd_fonts [OPTIONS]

Parameters list
  -u, --user=   Defines which user is the installation owner (default: $USER_NAME)
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

try_install_requirements_if_needed() {
    if [[ ! -x `which git` || ! -x `which curl` ]]; then
        if [ -x `which apt` ]; then
            exit_is_not_superuser
            apt update
            apt install -y git \
                           curl
        else
            e_echo 'You need to have git and curl installed.'
            exit 1
        fi
    fi
}

install_powerline_fonts() {
    if [ -e fonts ]; then rm -rf fonts; fi
    git clone "$URL_POWERLINE_FONT" --depth=1
    cd fonts
    sed -i "s|\$HOME|/home/$USER_NAME|g" install.sh
    ./install.sh
    cd .. && rm -rf fonts
}

install_nerd_fonts() {
    mkdir -p "/home/$USER_NAME/.local/share/fonts" || true
    cd "/home/$USER_NAME/.local/share/fonts"
    curl -fLo "Roboto Mono Nerd Font Complete Mono.ttf" \
              "$URL_ROBOTO_MONO_NERD_FONT"
    curl -fLo "Space Mono Nerd Font Complete Mono.ttf" \
              "$URL_SPACE_MONO_NERD_FONT"
}

set_right_owner() {
    if [ "$USER_NAME" != "$USER" ]; then
        chown -R "$USER_NAME:$USER_NAME" "/home/$USER_NAME"
    fi
}

main() {
    apply_options "$@"
    i_echo "Install Powerline and Nerd fonts"
    try_install_requirements_if_needed
    install_powerline_fonts
    install_nerd_fonts
    set_right_owner
    i_echo "Powerline and Nerd fonts installed successfully"
}

main "$@"
