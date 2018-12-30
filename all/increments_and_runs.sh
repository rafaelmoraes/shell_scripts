#!/bin/bash
# Author: Rafael Moraes <roliveira.moraes@gmail.com>
# Runs incrementally all executable files in the current directory

EXCLUDED_SCRIPTS=$(echo "$0" | sed 's/\.\///')
STORAGE='.current-configuration'
SCRIPTS=$(ls | sed "/$EXCLUDED_SCRIPTS/d")

# String to array
ARRAY_OF_SCRIPTS=($SCRIPTS)
# Get array size
ARRAY_SIZE=${#ARRAY_OF_SCRIPTS[@]}

if [ -e $STORAGE ]; then
    INDEX=$(cat $STORAGE)
else
    echo '' > "$STORAGE"
fi

if [[ -z $(cat $STORAGE) || $(( INDEX + 1 )) -ge "$ARRAY_SIZE" ]]; then
    INDEX=0
else
    INDEX=$(( INDEX + 1 ))
fi

CURRENT_SCRIPT=${ARRAY_OF_SCRIPTS[$INDEX]}
if [ -x "$CURRENT_SCRIPT" ]; then 
    ./"$CURRENT_SCRIPT"
else
    err="This script NOT is executable: $(pwd)/$CURRENT_SCRIPT"
    echo "$err"
    [ -e "$(which notify-send)" ] && notify-send "$err"
    INDEX=$(( INDEX + 1 ))
fi

echo $INDEX > $STORAGE
