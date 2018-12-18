#!/bin/sh
## Installs a Ruby on Rails environment on linux distribution Debian
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
echo "eval \"\$(rbenv init -)\"" >> "$HOME/.bashrc"

# Add Yarn respository
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
		tee /etc/apt/sources.list.d/yarn.list && apt-get update

# Install Rails dependencies
apt-get install nodejs yarn -y --no-install-recommends
apt-get install libpq-dev -y --no-install-recommends # PostgreSQL gem requirement

#Fix yarn nodejs binary path
echo 'alias node=nodejs' >> "$HOME/.bashrc"

# Install ruby if found a .ruby-version or install the latest stable ruby
RBENV_BIN="$HOME/.rbenv/bin/rbenv"
GEM_BIN="$HOME/.rbenv/shims/gem"
BUNDLE_BIN="$HOME/.rbenv/shims/bundle" 

if [ -e .ruby-version ]; then
  echo "Found .ruby-version file"
  RUBY_VERSION="$(cat .ruby-version)"
else
  echo "Not found .ruby-version file, installing the latest stable ruby version"
  RUBY_VERSION=$($RBENV_BIN install -l | grep -v - | tail -1)
fi

$RBENV_BIN install $RUBY_VERSION
$RBENV_BIN global $RUBY_VERSION
$GEM_BIN install bundle

# Install the GEMS if found a Gemfile else install the latest stable rails
if [ -e Gemfile ]; then
  echo "Found Gemfile"
  $BUNDLE_BIN install --gemfile=Gemfile
else
  echo "Not found Gemfile, installing the latest stable ruby on rails version"
  $GEM_BIN install rails
fi

# Cleanup if running in docker container
if grep -q 'docker' '/proc/1/cgroup'; then
    echo 'Cleanup...'
    rm -rf /var/lib/apt/lists/*;
fi
