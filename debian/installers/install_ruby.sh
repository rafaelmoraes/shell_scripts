#!/bin/bash
##############################################################################
# install_ruby.sh
# -----------
# Script to install the latest stable Ruby or the version present
# in .ruby-version if they exist
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-02-15
# :VERSION: 0.0.1
##############################################################################

set -euo pipefail

i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }

exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}

# VARIABLES
URL_RBENV='https://github.com/rbenv/rbenv.git'
URL_RUBY_BUILD='https://github.com/sstephenson/ruby-build.git'

FORCE=false
RUBY_VERSION=''
NEED_SETUP_BASE=true
TARGET_USER="$(whoami)"
TARGET_HOME="$HOME"
HELP_MESSAGE="Usage: ./install_ruby.sh [OPTIONS]

Parameters list
    -u, --user=             Set the user target of the installation (default: $HOME)
    -rv, --ruby-version=    Set ruby version to install (default: latest)
    -f, --force             Force reinstallation of rbenv and ruby (default: $FORCE)
    -h, --help              Show usage"

apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u)
                TARGET_USER="$2"
                TARGET_HOME="/home/$TARGET_USER"
                shift 2
            ;;
            --user=*)
                TARGET_USER="${1#*=}"
                TARGET_HOME="/home/$TARGET_USER"
                shift 1
            ;;
            -rv)
                RUBY_VERSION="$2"
                shift 2
            ;;
            --ruby-version=*)
                RUBY_VERSION="${1#*=}"
                shift 1
            ;;
            -f|--force)
                FORCE=true
                shift 1
            ;;
            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

_set_up_base() {
    if [ $NEED_SETUP_BASE ]; then
        export LC_ALL=C
        export LANG=en_US.utf8
        export LANGUAGE=en_US.utf8
        export DEBIAN_FRONTEND=noninteractive

        apt update
        apt upgrade -y
        apt install -y --no-install-recommends \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            curl \
            git
        NEED_SETUP_BASE=false
    fi
}

_install_ruby_requeriments() {
    _set_up_base
    apt-get install -y --no-install-recommends \
            curl \
            git \
            autoconf \
            bison \
            build-essential \
            libssl-dev \
            libyaml-dev \
            libreadline6-dev \
            zlib1g-dev \
            libncurses5-dev \
            libffi-dev \
            libgdbm3 \
            libgdbm-dev
}

_run_as_target_user() {
    runuser -l "$TARGET_USER" -c "$@"
}

_set_target_ruby_version() {
    if [ -z "$RUBY_VERSION" ]; then
        if [ -e .ruby-version ]; then
            i_echo "Found .ruby-version"
            RUBY_VERSION="$(cat .ruby-version)"
        else
            w_echo "Not found .ruby-version"
            i_echo "Installing the latest stable ruby version"
            RUBY_VERSION=$(_run_as_target_user "$RBENV_BIN install -l" |\
                           grep -v - |\
                           awk '{ print $NF }' |\
                           tail -1)
        fi
    fi
}

_set_current_ruby_version() {
    if [ -z "$(which ruby)" ]; then
        CURRENT_RUBY_VERSION=''
    else
        CURRENT_RUBY_VERSION="$(ruby -v | awk '{ print $2 }')"
    fi
}

install_rbenv_and_plugins() {
    if [ -e "$TARGET_HOME/.rbenv" ] && [ $FORCE == true ]; then
        rm -rf "$TARGET_HOME/.rbenv"
    fi
    if [ ! -e "$TARGET_HOME/.rbenv" ]; then
        _set_up_base
        git clone "$URL_RBENV" "$TARGET_HOME/.rbenv"
        git clone "$URL_RUBY_BUILD" "$TARGET_HOME/.rbenv/plugins/ruby-build"
        if ! grep -q 'rbenv/bin' "$TARGET_HOME/.bashrc"; then
            echo 'export PATH=$HOME/.rbenv/bin:$PATH' >> "$TARGET_HOME/.bashrc"
        fi
        if ! grep -q '(rbenv init -)' "$TARGET_HOME/.bashrc"; then
            echo "eval \"\$(rbenv init -)\"" >> "$TARGET_HOME/.bashrc"
        fi
        chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME"
    else
       w_echo "Rbenv already installed."
       i_echo "Update ruby versions available."
       cd "$TARGET_HOME/.rbenv/plugins/ruby-build"
       git pull &> /dev/null
    fi
    RBENV_BIN="$TARGET_HOME/.rbenv/bin/rbenv"
    GEM_BIN="$TARGET_HOME/.rbenv/shims/gem"
}

install_ruby_and_bundler() {
    _set_current_ruby_version
    _set_target_ruby_version
    if [[ $CURRENT_RUBY_VERSION =~ $RUBY_VERSION && $FORCE == false ]]; then
        w_echo "Ruby $CURRENT_RUBY_VERSION already installed."
    else
        if ! echo "$($RBENV_BIN versions)" | grep -q "$RUBY_VERSION"; then
            _install_ruby_requeriments
            _run_as_target_user "$RBENV_BIN install -s $RUBY_VERSION"
        fi
        _run_as_target_user "$RBENV_BIN global $RUBY_VERSION"
        _run_as_target_user "$GEM_BIN install bundle"
    fi
}

cleanup_if_docker() {
    if grep -q 'docker' '/proc/1/cgroup'; then
        rm -rf /var/lib/apt/lists/*;
    fi
}

main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo "Install Ruby through Rbenv"

    source ~/.bashrc
    install_rbenv_and_plugins
    install_ruby_and_bundler
    cleanup_if_docker

    i_echo "Install Ruby through Rbenv done"
}

main "$@"
