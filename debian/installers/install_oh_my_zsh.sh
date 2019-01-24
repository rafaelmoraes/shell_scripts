#!/bin/bash
##############################################################################
# install_oh_my_zsh.sh
# -----------
# Sript to install Oh-My-Zsh with simpler-zsh-theme
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-24
# :VERSION: 0.0.2
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
    if [ $# -eq 2 ]; then DEST="$2$suffix"; else DEST="$1$suffix"; fi
    cp -r "$1" "$DEST"
}

# VARIABLES
INSTALLATION_PATH=""
USER_NAME=""
DEFAULT_USER_NAME=${SUDO_USER:-$USER}
DEFAULT_INSTALLATION_PATH="/home/$DEFAULT_USER_NAME"
HELP_MESSAGE="Usage: ./install_oh_my_zsh.sh [OPTIONS]

Parameters list
  -u, --user=    Sets target user of the installation (default: $DEFAULT_USER_NAME)
  -p, --path=    Sets where the Oh-My-Zsh will be installed (default: $DEFAULT_INSTALLATION_PATH)
  -h, --help     Show usage."

apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -p) INSTALLATION_PATH="$2"; shift 2;;
            --path=*) INSTALLATION_PATH="${1#*=}"; shift 1;;
            -u) USER_NAME="$2"; shift 2;;
            --user=*) USER_NAME="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

set_values() {
    if [[ -z "$INSTALLATION_PATH" && ! -z "$USER_NAME" ]]; then
        INSTALLATION_PATH="/home/$USER_NAME"
    fi
    if [ -z "$INSTALLATION_PATH" ]; then
        INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
    fi
    if [ -z "$USER_NAME" ]; then USER_NAME="$DEFAULT_USER_NAME"; fi
    # root is a special case
    if [ "$USER_NAME" == 'root' ]; then INSTALLATION_PATH='/root'; fi
}

try_install_requirements_if_needed() {
    if [[ ! -x `which zsh` || ! -x `which git` || ! -x `which curl` ]]; then
        if [ -x `which apt` ]; then
            apt update
            apt install -y zsh \
                           git \
                           curl
        else
            e_echo 'You need have installed zsh, git and curl.'
        fi
    fi
}

install_theme() {
    if [ -e ./simpler-zsh-theme ]; then rm -rf ./simpler-zsh-theme; fi
    git clone https://github.com/rafaelmoraes/simpler-zsh-theme
    mkdir -p "$INSTALLATION_PATH/.oh-my-zsh/custom/themes" || true
    cp ./simpler-zsh-theme/simpler.zsh-theme \
        "$INSTALLATION_PATH/.oh-my-zsh/custom/themes"
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="simpler"/' "$INSTALLATION_PATH/.zshrc"
    rm -rf ./simpler-zsh-theme
}

install() {
    if [ -e "$INSTALLATION_PATH/.oh-my-zsh" ]; then
        rm -rf "$INSTALLATION_PATH/.oh-my-zsh"
    fi

    git clone https://github.com/robbyrussell/oh-my-zsh.git \
              "$INSTALLATION_PATH/.oh-my-zsh"

    if [ -e "$INSTALLATION_PATH/.zshrc" ]; then
        backup_file "$INSTALLATION_PATH/.zshrc"
    fi

    cp "$INSTALLATION_PATH/.oh-my-zsh/templates/zshrc.zsh-template" \
       "$INSTALLATION_PATH/.zshrc"
}

set_zsh_as_default_shell() {
    sed -i "s|$USER_NAME:/bin/bash|$USER_NAME:/bin/zsh|g" /etc/passwd
}

set_right_owner() {
    if [ "$USER_NAME" != "$USER" ]; then
        chown -R "$USER_NAME:$USER_NAME" "$INSTALLATION_PATH"
    fi
}

main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo "Install Oh My Zsh"
    set_values
    try_install_requirements_if_needed
    install
    install_theme
    set_right_owner
    set_zsh_as_default_shell
    i_echo 'Oh My Zsh installed successfully'
}

main "$@"
