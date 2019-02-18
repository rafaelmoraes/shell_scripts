#!/bin/bash
##############################################################################
# install_ruby_on_rails.sh
# -----------
# Script to install the Ruby on Rails on Debian
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-02-18
# :VERSION: 1.0.0
##############################################################################

set -euo pipefail

i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }

exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}

# VARIABLES
URL_SCRIPT_INSTALL_RUBY='https://raw.githubusercontent.com/rafaelmoraes/shell_scripts/master/debian/installers/install_ruby.sh'
RAILS_VERSION='latest'
RUBY_VERSION='latest'
CURRENT_RUBY_VERSION=''
FORCE=false
DATABASE="postgresql"
TARGET_USER="$(whoami)"
TARGET_HOME="$HOME"
HELP_MESSAGE="Usage: ./install_ruby_on_rails.sh [OPTIONS]

Parameters list
    -rav, --rails-version=    Set ruby on rails version to install (default: $RAILS_VERSION)
    -rv, ruby-version=        Set ruby version to install (default: $RUBY_VERSION)
    -db, --database=          Set the database supported (default: $DATABASE)
    -u, --user=               Set the user target of the installation (default: $HOME)
    -f, --force               Force reinstallation of rbenv and ruby (default: $FORCE)
    -h, --help                Show usage"

set_target() {
    TARGET_USER="$1"
    if [ "$1" == 'root' ]; then
        TARGET_HOME='/root'
    else
        TARGET_HOME="/home/$TARGET_USER"
    fi
}

apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -rv)
                RUBY_VERSION="$2"
                shift 2
            ;;
            --ruby-version=*)
                RUBY_VERSION="${1#*=}"
                shift 1
            ;;
            -rav)
                RAILS_VERSION="$2"
                shift 2
            ;;
            --rails-version=*)
                RAILS_VERSION="${1#*=}"
                shift 1
            ;;
            -db)
                DATABASE="$2"
                shift 2
            ;;
            --database=*)
                DATABASE="${1#*=}"
                shift 1
            ;;
            -u)
                set_target "$2"
                shift 2
            ;;
            --user=*)
                set_target "${1#*=}"
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

set_up_base() {
    export DEBIAN_FRONTEND=noninteractive
    set +u
    if [ -z "$LC_ALL" ]; then export LC_ALL=C; fi
    if [ -z "$LANG" ]; then export LANG=en_US.utf8; fi
    if [ -z "$LANGUAGE" ]; then export LANGUAGE=en_US.utf8; fi
    set -u
    apt update
    apt upgrade -y
    apt install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg
}

install_javascript_support() {
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
		  tee /etc/apt/sources.list.d/yarn.list
    apt-get update
    apt-get install -y --no-install-recommends \
            nodejs \
            yarn
    if ! grep -q 'node=nodejs' "$TARGET_HOME/.bashrc"; then
        echo 'alias node=nodejs' >> "$HOME/.bashrc"
    fi
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME"
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

_run_as_target_user() {
    runuser -l "$TARGET_USER" -c "$@"
}

install_ruby(){
    source "$TARGET_HOME/.bashrc"

    script_name="install_ruby_$(date +%s).sh"
    curl -o "$script_name" "$URL_SCRIPT_INSTALL_RUBY"
    chmod +x "$script_name"

    options="-u $TARGET_USER"

    if [ "$RUBY_VERSION" != 'latest' ]; then
        options="$options -rv $RUBY_VERSION"
    fi

    if [ $FORCE == true ]; then
        options="$options --force"
    fi
    ./$script_name $options
    rm -f "$script_name"
    source "$TARGET_HOME/.bashrc"
}

install_rails() {
    if [ "$RAILS_VERSION" != 'latest' ]; then
        i_echo "Installing Ruby on Rails $RAILS_VERSION"
        _run_as_target_user "gem install rails -v $RAILS_VERSION"
    elif [ -e Gemfile ]; then
        i_echo "Found Gemfile"
        _run_as_target_user "bundle install --gemfile=$(pwd)/Gemfile"
    else
        w_echo "Not found Gemfile"
        i_echo "Installing the latest stable ruby on rails version"
        _run_as_target_user "gem install rails"
    fi
}

main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo "Install Ruby on Rails"

    set_up_base
    install_ruby
    install_javascript_support
    install_database_support
    install_rails

    i_echo "Ruby on Rails installed successfully"
}

main "$@"
