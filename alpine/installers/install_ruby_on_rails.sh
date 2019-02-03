#!/bin/bash
##############################################################################
# install_ruby_on_rails.sh
# -----------
# Script to install Ruby on Rails on Alpine Linux
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-30
# :VERSION: 0.0.1
##############################################################################

set -euo pipefail

i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }

NO_INSTALL_GEM_DOCS=false
RBENV_BIN="$HOME/.rbenv/bin/rbenv"
GEM_BIN="$HOME/.rbenv/shims/gem"
BUNDLE_BIN="$HOME/.rbenv/shims/bundle"
USAGE="Usage: ./install_ruby_on_rails.sh [OPTIONS]

Options Available
    --no-gem-doc      Don't install the GEMs documentations (default: $NO_INSTALL_GEM_DOCS)

    -h, --help        Show usage
"

set_up_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --no-gem-doc) NO_INSTALL_GEM_DOCS=true; shift 1;;
            -h|--help) echo "$USAGE"; exit 0;;
            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

install_requirements() {
    i_echo 'Install requirements'
    apk update
    apk upgrade
    apk add --no-cache \
		bzip2 \
		bzip2-dev \
		ca-certificates \
		coreutils \
		dpkg-dev \
		gdbm-dev \
		glib-dev \
		libc-dev \
		libffi-dev \
		libxml2-dev \
		libxslt-dev \
		linux-headers \
		make \
		procps \
		tar \
		xz \
		yaml-dev \
        autoconf \
        bash \
        bison \
        build-base \
        curl \
        dpkg \
        gcc \
        gdbm-dev \
        git \
        libffi-dev \
        ncurses-dev \
        openssl-dev \
        readline-dev \
        yaml-dev \
        zlib-dev
}

install_rbenv_and_ruby_build() {
    i_echo 'Install Rbenv and Ruby Build plugin'
    if [ -e "$HOME/.rbenv" ]; then rm -rf "$HOME/.rbenv"; fi
    git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
    git clone https://github.com/sstephenson/ruby-build.git \
        "$HOME/.rbenv/plugins/ruby-build"
    echo "export PATH=\"$HOME/.rbenv/bin:$PATH\"" >> "$HOME/.bashrc"
    echo "eval \"\$(rbenv init -)\"" >> "$HOME/.bashrc"
}

install_ruby() {
    i_echo 'Install Ruby'

    if [ -e .ruby-version ]; then
      i_echo "Found .ruby-version file"
      RUBY_VERSION="$(cat .ruby-version)"
    else
      w_echo "Not found .ruby-version file, installing the latest ruby stable version"
      RUBY_VERSION=$(bash -c "$RBENV_BIN install -l" | grep -v - | tail -1)
    fi

    bash -c "$RBENV_BIN install $RUBY_VERSION"
    bash -c "$RBENV_BIN global $RUBY_VERSION"
    bash -c "$GEM_BIN install bundle"
}

install_rails_requirements() {
    i_echo 'Install Rails requirements'
    apk add --no-cache \
        nodejs \
        yarn \
        libpq # PostgreSQL gem requirement
}

install_gems() {
    i_echo 'Install Gems'
    if [ -e Gemfile ]; then
      i_echo "Found Gemfile"
      $BUNDLE_BIN install --gemfile=Gemfile
    else
      w_echo "Not found Gemfile, installing the latest stable ruby on rails version"
      $GEM_BIN install rails
    fi
}

clean_up() {
    rm -rf /var/cache/apk/*
}

set_up_gem_documentaion() {
    if [ $NO_INSTALL_GEM_DOCS ]; then
        GEMRC='
install: --no-document
update: --no-document'
        export GEMRC
        echo "$GEMRC" > $HOME/.gemrc
    fi
}

main() {
    set_up_options "$@"

    i_echo 'Install Ruby on Rails'

    set_up_gem_documentaion
    install_requirements
    install_rbenv_and_ruby_build
    install_ruby
    install_rails_requirements
    install_gems
    clean_up

    i_echo "Ruby on Rails installed successfully"
}

main "$@"
