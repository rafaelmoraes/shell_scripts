#!/bin/bash
# AUTHOR: Rafael Moraes <roliveira.moraes@gmail.com>
# DESCRIPTION: Script to fix video tearing on Intel Graphics cards

# Configure bash unofficial strict mode
# -e: Exits if any command return non zero state
# -u: Exits if you reference a non declared variable
# -o pipefail: Exits if any command on pipeline return non zero state
set -euo pipefail

# HELPERS
i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }
exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then
        w_echo "Run as root or using sudo."
        exit 1
    fi
}

create_directory_if_needed() {
    mkdir -p /etc/X11/xorg.conf.d || true
}

create_configuration_file() {
echo 'Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
   Option      "TripleBuffer" "true"
   Option      "TearFree"     "true"
   Option      "DRI"          "true"
EndSection' > /etc/X11/xorg.conf.d/20-intel-graphics.conf
}

exit_is_not_superuser
gpu_found="$(lspci | grep 'Intel Corporation HD Graphics')"
if [ -z "$gpu_found" ]; then
    i_echo 'Intel GPU not found'
else
    i_echo 'Fixing Intel video tearing.'
    create_directory_if_needed
    create_configuration_file
    i_echo 'Intel Video tearing fixed successfully.'
fi

