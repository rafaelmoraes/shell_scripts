#!/bin/bash
##############################################################################
# configure_my_dotfiles.sh
# -----------
# Script to install and configure my dotfiles
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-26
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
    if [ $# -eq 2 ]; then dest="$2$suffix"; else dest="$1$suffix"; fi
    cp -r "$1" "$dest"
}
# VARIABLES
URL_GIT_REPOSITORY='https://github.com/rafaelmoraes/dotfiles.git'
USER_NAME=${SUDO_USER:-$USER}
TMP_DIR="/tmp/dotfiles-$(date +%s)"
HELP_MESSAGE="Usage: ./configure_my_dotfiles.sh [OPTIONS]

Parameters list
  -u, --user=   Defines the owner of the files (default: $USER_NAME)
  -h, --help    Show help."

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u)
                USER_NAME="$2"
                shift 2;;
            --user=*)
                USER_NAME="${1#*=}"
                shift 1;;
            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

set_user_home() {
    if [ "$USER_NAME" == 'root' ]; then
        USER_HOME='/root';
    else
        USER_HOME="/home/$USER_NAME"
    fi
}

try_install_git_if_needed() {
    if [ -z "$(which git)" ]; then
        if [ ! -z "$(which apt)" ]; then
            exit_is_not_superuser
            apt update
            apt install -y git
        else
            e_echo 'Please install git and try again'
        fi
    fi
}

clone_repository() {
   git clone "$URL_GIT_REPOSITORY" "$TMP_DIR"
}

extract_directory_path() {
    file_path="$1"
    file_name=$(echo "$file_path" | awk -F'/' '{ print $NF }')
    dir_path=${file_path//\/$file_name/''}
    echo "$dir_path"
}

created_backup_if_needed() {
    file="$1"
    if [ -f "$USER_HOME/$file" ]; then
        backup_file "$USER_HOME/$file"
    fi
}

create_directory_if_needed() {
    file="$1"
    dir_path=$(extract_directory_path "$file")
    if [ ! -e "$USER_HOME/$dir_path" ]; then
        mkdir -p "$USER_HOME/$dir_path"
    fi
}

fix_git_repository() {
    if [ -e "$USER_HOME/.git" ]; then
        rm -rf "$USER_HOME/.git"
    fi
    mv .git "$USER_HOME/.git"
    cd "$USER_HOME"
    git reset --hard HEAD >/dev/null 2>&1
}

install_dotfiles() {
    if [ ! -e "$USER_HOME" ]; then mkdir -p "$USER_HOME"; fi
    cd "$TMP_DIR"
    list_of_tracked_files=$(git ls-tree --full-tree -r --name-only HEAD)
    for file in $list_of_tracked_files; do
        created_backup_if_needed "$file"
        create_directory_if_needed "$file"
        cp "$file" "$USER_HOME/$file"
    done
    fix_git_repository
    rm -rf "$TMP_DIR"
}

set_right_owner() {
    if [ "$USER_NAME" != "$USER" ]; then
        exit_is_not_superuser
        chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"
    fi
}

main() {
    apply_options "$@"
    i_echo "Install and configure my dotfiles"
    set_user_home
    try_install_git_if_needed
    clone_repository
    install_dotfiles
    set_right_owner
    i_echo "Dotfiles configured successfully"
}

main "$@"
