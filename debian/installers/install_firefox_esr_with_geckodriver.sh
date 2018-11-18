#!/bin/sh
## Installs Firefox ESR and Geckodrive on linux distribution Debian
[ -z "$LC_ALL" ]   && export LC_ALL=C
[ -z "$LANG" ]     && export LANG=en_US.utf8
[ -z "$LANGUAGE" ] && export LANGUAGE=en_US.utf8

GECKODRIVER_URL='https://github.com/mozilla/geckodriver/releases/download/v0.23.0/geckodriver-v0.23.0-linux64.tar.gz'

# Configure debconf to run in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Install general dependencies
apt update && apt install -y --no-install-recommends \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg

# Install Firefox ESR
apt install -y --no-install-recommends firefox-esr

# Install Geckodrive
curl -OL "$GECKODRIVER_URL" &&
tar -xzvf geckodriver*.tar.gz &&
rm geckodriver*.tar.gz &&
chmod +x geckodriver &&
mv geckodriver /usr/bin &&

# Cleanup if running in docker container
if grep -q 'docker' '/proc/1/cgroup'; then
    echo 'Cleanup...'
    rm -rf /var/lib/apt/lists/*;
fi
