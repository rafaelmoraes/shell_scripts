#!/bin/bash -x
##############################################################################
# install_hadolint.sh
# -----------
# Script to install the hadolint (Dokerfile linter) on Debian and Alpine
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-02-01
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
DIST=''
URL_SCRIPT_INSTALL_SHELLCHECK='https://raw.githubusercontent.com/rafaelmoraes/shell_scripts/master/all/installers/install_shellcheck.sh'
URL_SCRIPT_INSTALL_STACK='https://raw.githubusercontent.com/rafaelmoraes/shell_scripts/master/all/installers/install_haskell_tool_stack.sh'
URL_HADOLINT='https://github.com/hadolint/hadolint'
TMP_DIR="/tmp/hadolint-instalation-$(date +%s)"
HELP_MESSAGE="[CHANGE OR DELETE ME] Usage: runnable [OPTIONS]

Parameters list
  -f, --foo=    Says to script do something...
  -h, --help    Show help."

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            #[CHANGE OR DELETE ME]
            -f) FOO="$2"; shift 2;;
            --foo=*) FOO="${1#*=}"; shift 1;;
            #[CHANGE OR DELETE ME]
            -b) BAR="$2"; shift 2;;
            --bar=*) BAR="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}


#[CHANGE OR DELETE ME] Write your functions here, like below.
example() {
    echo "$FOO, $BAR"
}

detect_linux_dist() {
    if [ -x "$(which apt)" ]; then
        DIST='debian'
    elif [ -x "$(which apk)" ]; then
        DIST='alpine'
    else
        e_echo 'No was possible to detect the linux distribution'.
        exit 1
    fi
}

deb_install_requirements() {
    apt update
    apt install -y git \
                   sed \
                   curl
}

alpine_install_requirements() {
    apk update
    apk add --no-cache git \
                       sed \
                       curl
}

common_install_requirements() {
    if [ ! -x "$(which stack)" ]; then
        if [ ! -e "$TMP_DIR" ]; then mkdir -p "$TMP_DIR"; fi
        script="$TMP_DIR/install_haskell_tool_stack_$(date +%s)"
        curl -sSL "$URL_SCRIPT_INSTALL_STACK" -o "$script"
        chmod +x "$script"
        bash "$script"
    fi

    if [ ! -x "$(which shellcheck)" ]; then
        if [ ! -e "$TMP_DIR" ]; then mkdir -p "$TMP_DIR"; fi
        script="$TMP_DIR/install_shellcheck_$(date +%s).sh"
        curl -sSL $URL_SCRIPT_INSTALL_SHELLCHECK -o "$script"
        chmod +x "$script"
        bash "$script"
    fi
}

clone_and_cd_hadolint() {
    git clone "$URL_HADOLINT" "$TMP_DIR/hadolint"
    cd "$TMP_DIR/hadolint"
}

deb_install() {
    deb_install_requirements
    common_install_requirements
    deb_install_hadolint
}

alpine_install() {
    alpine_install_requirements
    common_install_requirements
    alpine_install_hadolint
}

deb_install_hadolint() {
    clone_and_cd_hadolint
    stack install --fast
}

alpine_install_hadolint() {
    clone_and_cd_hadolint
    sed -i -r 's/lts.+/lts-12.14/' stack.yaml
    echo '- language-docker-8.0.0' >> stack.yaml
    echo 'system-ghc: true' >> stack.yaml
    stack update
    stack install --fast
}

add_in_path_env_var() {
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        if [ -f "$HOME/.bashrc" ]; then
            rc_file="$HOME/.bashrc"
        elif [ -f "$HOME/.zshrc" ]; then
            rc_file="$HOME/.zshrc"
        else
            rc_file="$HOME/.bashrc"
        fi
        echo 'export PATH=$PATH:$HOME/.local/bin' >> "$rc_file"
        export PATH=$PATH:$HOME/.local/bin
    fi
}

main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo 'Install hadolint, a linter for Dockerfile'
    detect_linux_dist

    case "$DIST" in
        debian )
            deb_install
            ;;
        alpine )
            alpine_install
            ;;
    esac

    add_in_path_env_var

    i_echo 'Hadolint installed successfully'
}

main "$@"
