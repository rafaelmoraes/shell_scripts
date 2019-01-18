#!/bin/bash
# Author: Rafael Moraes <roliveira.moraes@gmail.com>
# Script to help to create another scripts, like the Ruby on Rails scaffold

# DEFAULT VARIABLES
AUTHOR='Rafael Moraes <roliveira.moraes@gmail.com>'
DESCRIPTION='[CHANGE OR DELETE ME] Write here what this script do...'
HELP_MESSAGE="[CHANGE OR DELETE ME] Usage: shell_scaffold path_and_script_name [OPTIONS]

Parameters list
  -a, --author=         Sets author information (default: $AUTHOR)
  -d, --description=    Sets script description
  -h, --help            Show help

Example
  shell_scaffold ~/scripts/my_script.sh -d 'My script'
"

## Helpers
i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }
exit_is_not_superuser() {
    [ "$(id -u)" != "0" ] && w_echo "Run as root or using sudo." && exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -a) AUTHOR="$2"; shift 2;;
        --author=*) AUTHOR="${1#*=}"; shift 1;;

        -d) DESCRIPTION="$2"; shift 2;;
        --description=*) DESCRIPTION="${1#*=}"; shift 1;;

        -h|--help) echo "$HELP_MESSAGE"; exit 0;;

        -*) echo "Unknown option: $1" >&2; exit 1;;

        *) SCRIPT=$1; shift 1;;
    esac
done

HEADER="#!/bin/bash
##############################################################################
# $SCRIPT
# -----------
# $DESCRIPTION
#
#
# :AUTHORS: $AUTHOR
# :DATE: $(date +%Y-%m-%d)
# :VERSION: 0.0.1
##############################################################################
"

STRICT_MODE="# Configure bash unofficial strict mode
# -e: Exits if any command return non zero state
# -u: Exits if you reference a non declared variable
# -o pipefail: Exits if any command on pipeline return non zero state
set -euo pipefail
#IFS=$'\n\t'  # Sets bash word splitting as break-line and/or tab
"

LOG_HELPERS='i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }
'
CHECK_HELPERS='exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}
'
BACKUP_HELPERS='backup_file() {
    if [ $# -eq 0 ]; then e_echo "Backup failed, you need to give a file path."; exit 1; fi
    if [ ! -e "$1" ]; then e_echo "Backup failed, file not found: $1"; exit 1; fi
    suffix="-BACKUP-$(date +%Y-%m-%d--%H-%M-%S)"
    if [ $# -eq 2 ]; then DEST="$2$suffix"; else DEST="$1$suffix"; fi
    cp -r "$1" "$DEST"
}
'
DEFAULT_VARIABLES='# VARIABLES
FOO="FOO" #[CHANGE OR DELETE ME]
BAR="BAR" #[CHANGE OR DELETE ME]
HELP_MESSAGE="[CHANGE OR DELETE ME] Usage: runnable [OPTIONS]

Parameters list
  -f, --foo=    Says to script do something...
  -h, --help    Show help."
'

READ_OPTIONS='# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            #[CHANGE OR DELETE ME]
            -f) FOO="$2"; shift 2;;
            --foo=*) FOO="${1#*=}"; shift 1;;
            #[CHANGE OR DELETE ME]
            -b) BAR="$2"; shift 2;;
            --bar=*) BAR="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            -*) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}
'

MAIN_CONTENT='
#[CHANGE OR DELETE ME] Write your functions here, like below.
example() {
    echo "$FOO, $BAR"
}


main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo "[CHANGE OR DELETE ME] Script begin do something...."

    #[CHANGE OR DELETE ME] Run your functions here, as below.
    example

    i_echo "[CHANGE OR DELETE ME] Script finished..."
}

main "$@"'

generate_script() {
    {
        echo "$HEADER"
        echo "$STRICT_MODE"
        echo "$LOG_HELPERS"
        echo "$CHECK_HELPERS"
        echo "$BACKUP_HELPERS"
        echo "$DEFAULT_VARIABLES"
        echo "$READ_OPTIONS"
        echo "$MAIN_CONTENT"
    } > "$SCRIPT"

    sudo chmod +x "$SCRIPT"
}

main() {
    generate_script
}

main
