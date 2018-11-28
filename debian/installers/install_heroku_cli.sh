#!/bin/sh
## Installs Heroku CLI on linux distribution Debian

if [ "$(id -u)" != "0" ]; then
  echo "This script requires superuser access."
  exit 1
fi

HEROKU_CLI_REPOSITORY_URL='https://cli-assets.heroku.com/apt'

[ -z "$LC_ALL" ]   && export LC_ALL=C
[ -z "$LANG" ]     && export LANG=en_US.utf8
[ -z "$LANGUAGE" ] && export LANGUAGE=en_US.utf8

# Configure debconf to run in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Install general dependencies
apt update && apt install -y --no-install-recommends \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg

# Add heroku's respository
echo "deb $HEROKU_CLI_REPOSITORY_URL ./" > /etc/apt/sources.list.d/heroku.list

# Install heroku's release key verification
curl https://cli-assets.heroku.com/apt/release.key | apt-key add -

apt update && apt install -y --no-install-recommends heroku

# Cleanup if running in docker container
if grep -q 'docker' '/proc/1/cgroup'; then
    echo 'Cleanup...'
    rm -rf /var/lib/apt/lists/*;
fi
