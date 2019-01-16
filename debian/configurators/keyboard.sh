#!/bin/sh

## Author: Rafael Moraes <roliveira.moraes@gmail.com>
# This script configures keyboard layout on Debian.
# The old file is moved as backup and a new one is created.
# Default layouts
# - br (Brazilian Portuguese)
# - us_intl (English International)

# RESOURCES: https://wiki.debian.org/Keyboard

## Helpers
i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }
exit_is_not_superuser() {
    [ "$(id -u)" != "0" ] && w_echo "Run as root or using sudo." && exit 1
}

# DEFAULTS
KEYBOARD_LAYOUTS='br,us_intl'
KEYBOARD_MODEL='pc105'
TOGGLE_SHORTCUT='grp:alt_shift_toggle'
KEYBOARD_VARIANT=''
BACKSPACE='guess'
CONFIG_FILE_PATH='/etc/default/keyboard'
HELP_MESSAGE="Usage: ./keyboard.sh [OPTIONS]

Parameters list
  -l, --layouts=    Set keyboard layouts (default: '$KEYBOARD_LAYOUTS')
  -m, --model=      Set Keyboard model (default: '$KEYBOARD_MODEL')
  -s, --shortcut=   Set shortcut to toggle keyboard layout (default: '$TOGGLE_SHORTCUT')
  -v, --variant=    Set keyboard variant (default: '$KEYBOARD_VARIANT')
  -b, --backspace=  Set backspace button (default: '$BACKSPACE')

  Examples
# Set keyboard layouts br,us,fr and keyboard model pc101
  sudo ./keyboard.sh -l 'br,us,fr' -m 'pc101'

# Set Keyboard layouts us,us_intl and shortcut to toggle layouts as <Ctrl><Shift>
  sudo ./keyboard.sh --layouts='us,us_intl' --shortcut='grp:ctrl_shift_toggle'"

##Reads the parameters passed by user
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -l) KEYBOARD_LAYOUTS="$2"; shift 2;;
            --layouts=*) KEYBOARD_LAYOUTS="${1#*=}"; shift 1;;

            -m) KEYBOARD_MODEL="$2"; shift 2;;
            --model=*) KEYBOARD_MODEL="${1#*=}"; shift 1;;

            -s) TOGGLE_SHORTCUT="$2"; shift 2;;
            --shortcut=*) TOGGLE_SHORTCUT="${1#*=}"; shift 1;;

            -v) KEYBOARD_VARIANT="$2"; shift 2;;
            --variant=*) KEYBOARD_VARIANT="${1#*=}"; shift 1;;

            -b) BACKSPACE="$2"; shift 2;;
            --backspace=*) BACKSPACE="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            -*) echo "Unknown option: $1" >&2; exit 1;;
        esac
     done
}

backup_previous_configs() {
    i_echo "Creating backup of previous configuration"
    mv $CONFIG_FILE_PATH "$CONFIG_FILE_PATH-BACKUP-$(date +%Y-%m-%d--%H-%M-%S)"
}

apply_new_configs() {
    i_echo "Creating new keyboard configuration file"
    echo "# KEYBOARD CONFIGURATION FILE
XKBMODEL='$KEYBOARD_MODEL'
XKBLAYOUT='$KEYBOARD_LAYOUTS'
XKBVARIANT='$KEYBOARD_VARIANT'
XKBOPTIONS='$TOGGLE_SHORTCUT'
BACKSPACE='$BACKSPACE'" > $CONFIG_FILE_PATH
}

main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo "Configure keyboard."
    backup_previous_configs &&
    apply_new_configs &&
    i_echo "Keyboard configured."
}

main "$@"
