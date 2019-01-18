#!/bin/bash
# AUTHOR: Rafael Moraes <roliveira.moraes@gmail.com>
# DESCRIPTION: This script improve the appearance of all fonts

# Configure bash unofficial strict mode
# -e: Exits if any command return non zero state
# -u: Exits if you reference a non declared variable
# -o pipefail: Exits if any command on pipeline return non zero state
set -euo pipefail
#IFS=$'\n\t'  # Sets bash word splitting as break-line and/or tab

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

exit_is_not_superuser

mkdir -p /etc/fonts || true

echo '<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="font">
        <edit name="antialias" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="autohint" mode="assign">
            <bool>false</bool>
        </edit>
        <edit name="embeddedbitmap" mode="assign">
            <bool>false</bool>
        </edit>
        <edit name="hinting" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
        </edit>
        <edit name="lcdfilter" mode="assign">
            <const>lcdlight</const>
        </edit>
        <edit name="rgba" mode="assign">
            <const>rgb</const>
        </edit>
    </match>
</fontconfig>' > /etc/fonts/local.conf

i_echo "Font improvements installed successfully."
