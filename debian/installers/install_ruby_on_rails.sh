#!/bin/bash
##############################################################################
# install_ruby_on_rails.sh
# -----------
# Script to install the latest stable Ruby on Rails or the version present on
# GEMFILE and .ruby-version if they exist
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-02-11
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
URL_RBENV='https://github.com/rbenv/rbenv.git'
URL_RUBY_BUILD='https://github.com/sstephenson/ruby-build.git'

RBENV_BIN="$HOME/.rbenv/bin/rbenv"
GEM_BIN="$HOME/.rbenv/shims/gem"
BUNDLE_BIN="$HOME/.rbenv/shims/bundle"

DATABASE="postgresql"
HELP_MESSAGE="Usage: ./install_ruby_on_rails.sh [OPTIONS]

Parameters list
    -db, --database=    Set the database supported (default: $DATABASE)
    -h, --help          Show usage"

apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -db) DATABASE="$2"; shift 2;;
            --database=*) DATABASE="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

set_up_base() {
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
        gnupg
}

install_ruby_requeriments() {
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

install_rbenv_and_plugins() {
    if [ -e "$HOME/.rbenv" ]; then rm -rf "$HOME/.rbenv"; fi
    git clone "$URL_RBENV" "$HOME/.rbenv"
    git clone "$URL_RUBY_BUILD" "$HOME/.rbenv/plugins/ruby-build"
    if ! grep -q 'rbenv/bin' "$HOME/.bashrc"; then
        echo "export PATH=\"$HOME/.rbenv/bin:$PATH\"" >> "$HOME/.bashrc"
    fi
    if ! grep -q '(rbenv init -)' "$HOME/.bashrc"; then
        echo "eval \"\$(rbenv init -)\"" >> "$HOME/.bashrc"
    fi
    if ! grep -q 'node=nodejs' "$HOME/.bashrc"; then
        echo 'alias node=nodejs' >> "$HOME/.bashrc"
    fi
}

install_nodejs_and_yarn() {
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
		  tee /etc/apt/sources.list.d/yarn.list
    apt-get update
    apt-get install -y --no-install-recommends \
            nodejs \
            yarn
}

install_database_support() {
    case $DATABASE in
        postgres|pg|postgresql )
            i_echo "Install PostgreSQL client support"
            pkgs='libpq-dev'
            ;;
        sqlite|sqlite3 )
            i_echo "Install SQLite 3 client support"
            pkgs='libsqlite3-dev'
            ;;
    esac
    if [ ! -z "$pkgs" ]; then
        apt install -y --no-install-recommends $pkgs
    fi
}

install_ruby_and_gems() {
    if [ -e .ruby-version ]; then
        i_echo "Found .ruby-version"
        RUBY_VERSION="$(cat .ruby-version)"
    else
        w_echo "Not found .ruby-version"
        i_echo "Installing the latest stable ruby version"
        RUBY_VERSION=$($RBENV_BIN install -l | \
                        grep -v - | \
                        awk '{ print $NF }' | \
                        tail -1)
    fi

    $RBENV_BIN install "$RUBY_VERSION"
    $RBENV_BIN global "$RUBY_VERSION"
    $GEM_BIN install bundle

    if [ -e Gemfile ]; then
        i_echo "Found Gemfile"
        $BUNDLE_BIN install --gemfile=Gemfile
    else
        w_echo "Not found Gemfile"
        i_echo "Installing the latest stable ruby on rails version"
        $GEM_BIN install rails
    fi
}

main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo "Install Ruby on Rails"

    set_up_base
    install_ruby_requeriments
    install_rbenv_and_plugins
    install_nodejs_and_yarn
    install_database_support
    install_ruby_and_gems

    i_echo "Ruby on Rails installed successfully"
}

main "$@"
