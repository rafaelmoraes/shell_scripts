#!/bin/sh

FONT_URL=${font_url:-"https://raw.githubusercontent.com/powerline/fonts/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf"}
CONFIG_URL=${config_url:-"https://raw.githubusercontent.com/rafaelmoraes/dockerfiles/master/vscode/local.conf"}
FONT_DIR=${font_dir:-"$HOME/.local/share/fonts"}

mkdir -p $FONT_DIR

if [ ! -x curl ]; then
    apt-get update && apt-get install curl -y
fi

curl -fLo "$FONT_DIR/Roboto Mono for Powerline.ttf" "$FONT_URL"

mkdir -p /etc/fonts/

curl -o /etc/fonts/local.conf "$CONFIG_URL"

if [ -x fc-cache ];then
    fc-cache -vf "$FONT_DIR"
fi
