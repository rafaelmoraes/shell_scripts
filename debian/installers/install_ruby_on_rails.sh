#!/bin/sh
## Installs a rails development environment on linux distribution Debian
export LC_ALL=C
export LANG=en_US.utf8
export LANGUAGE=en_US.utf8

# Configure debconf to run in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Install general dependencies
apt-get update && apt-get install -y --no-install-recommends \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg

# Install ruby dependencies
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

# Install RBENV(https://github.com/rbenv/rbenv) and yours helpers
git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
git clone https://github.com/sstephenson/ruby-build.git \
    "$HOME/.rbenv/plugins/ruby-build"
echo "export PATH=\"$HOME/.rbenv/bin:$PATH\"" >> "$HOME/.bashrc"
echo "eval \"$(rbenv init -)\"" >> "$HOME/.bashrc"

# Install Rails dependencies
apt-get install nodejs -y --no-install-recommends
apt-get install libpq-dev -y --no-install-recommends # PostgreSQL gem requirement

# Install ruby if found a .ruby-version
if [ -e .ruby-version ]; then
  "$HOME/.rbenv/bin/rbenv" install "$(cat .ruby-version)"
  "$HOME/.rbenv/bin/rbenv" global "$(cat .ruby-version)"
  "$HOME/.rbenv/shims/gem" install bundle
fi

# Install thee GEMS if found a Gemfile
if [ -e Gemfile ]; then
  "$HOME/.rbenv/shims/bundle" install --gemfile=Gemfile
fi

# Cleanup
rm -rf /var/lib/apt/lists/*;
