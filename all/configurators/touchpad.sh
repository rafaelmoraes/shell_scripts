#!/bin/bash
##############################################################################
# touchpad.sh
# -----------
# Script to configure touchpad of laptop DELL Vostro 14-5480
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-25
# :VERSION: 0.0.2
##############################################################################

set -euo pipefail
i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}

try_install_requirements_if_needed() {
    if [ -z "$(which xinput)" ]; then
        if [ -x "$(which apt)" ]; then
            apt update
            apt install -y xinput
        else
            w_echo 'You need to install: xinput'
        fi
    fi
}

apply_configuration() {
    xinput set-prop 'ETPS/2 Elantech Touchpad' \
                    'libinput Tapping Enabled' 1
    xinput set-prop 'ETPS/2 Elantech Touchpad' \
                    'libinput Natural Scrolling Enabled' 1
}

main() {
    exit_is_not_superuser
    i_echo 'Configure Dell Vostro 14-5480 Touchpad'
    try_install_requirements_if_needed
    apply_configuration
    i_echo "Touchpad configured successfully"
}

main "$@"
