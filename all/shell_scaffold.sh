#!/bin/sh
# Author: Rafael Moraes <roliveira.moraes@gmail.com>
# Script to help to create another scripts, like the Ruby on Rails scaffold

# DEFAULT VARIABLES
AUTHOR='Rafael Moraes <roliveira.moraes@gmail.com>'
DESCRIPTION='Write here what this script do...'
HELP_MESSAGE="Usage: shell_scaffold path_and_script_name [OPTIONS]

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

HEADER="#!/bin/sh/
# AUTHOR: $AUTHOR
# DESCRIPTION: $DESCRIPTION"

HELPERS='
# HELPERS
i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }
exit_is_not_superuser() {
    [ "$(id -u)" != "0" ] && w_echo "Run as root or using sudo." && exit 1
}'

DEFAULT_VARIABLES='
# DEFAULT VARIABLES
FOO="FOO"
BAR="BAR"
HELP_MESSAGE="Usage: runnable [OPTIONS]

Parameters list
  -f, --foo=    Says to script do something...
  -h, --help    Show help."
'

READ_OPTIONS='# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in

            -f) FOO="$2"; shift 2;;
            --foo=*) FOO="${1#*=}"; shift 1;;

            -b) BAR="$2"; shift 2;;
            --bar=*) BAR="${1#*=}"; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            -*) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}'

MAIN_CONTENT='
# Write your functions here, like below.
example() {
    echo "$FOO, $BAR"
}


main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo "Script begin do something...."

    # Run your functions here, as below.
    example

    i_echo "Script finished..."
}

main "$@"
'

generate_script() {
    {
        echo "$HEADER"
        echo "$HELPERS"
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
