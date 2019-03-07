#!/bin/bash
##############################################################################
# install_mongodb.sh
# -----------
# Script to install or uninstall the Mongo DB on Debian 8(Jessie) and 9(Stretch).
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-03-07
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
IS_INSTALL=true
URL_MONGODB_DEBIAN_8="deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/4.0 main"
URL_MONGODB_DEBIAN_9="deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main"
HELP_MESSAGE="Usage: ./install_mongodb.sh [OPTIONS]

Parameters list
  --uninstall   Uninstall previous installation and delete databases.
  -h, --help    Show help."

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --uninstall) IS_INSTALL=false; shift 1;;

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
        gnupg \
        dirmngr
}

detect_version() {
    DEBIAN_VERSION=$(grep VERSION_ID /etc/os-release | sed s/[^0-9+]//g)
}

choose_mongo_repository() {
    case $DEBIAN_VERSION in
        8 ) URL_MONGODB_REPO=$URL_MONGODB_DEBIAN_8;;
        9 ) URL_MONGODB_REPO=$URL_MONGODB_DEBIAN_9;;
    esac
}

add_repository_into_source_list () {
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
                --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
    echo "$URL_MONGODB_REPO" | tee /etc/apt/sources.list.d/mongodb-org.list
}

check_if_mongodb_works() {
    service mongod start
    sleep 3
    if grep -q 'waiting for connections' /var/log/mongodb/mongod.log; then
        i_echo "MongoDB installed succefully. =]"
    else
        e_echo "MongoDB installation failed. =["
    fi
}

install_mongodb() {
    i_echo "Install MongoDB"
    set_up_base
    detect_version
    choose_mongo_repository
    add_repository_into_source_list
    apt update
    apt install -y mongodb-org
    check_if_mongodb_works
}

uninstall_mongodb() {
    w_echo "The MongoDB and your data will be deleted permanently, are you wish to continue? (y|n)"
    read -r proceed
    if [ "$proceed" == 'y' ]; then
        apt purge mongodb-org*
        rm -r /var/log/mongodb
        rm -r /var/lib/mongodb
        i_echo "MongoDB purged successfully."
    else
        i_echo "Uninstall aborted."
    fi
}

main() {
    apply_options "$@"
    exit_is_not_superuser
    if [ "$IS_INSTALL" == "true" ]; then
        install_mongodb
    else
        uninstall_mongodb
    fi
}

main "$@"
