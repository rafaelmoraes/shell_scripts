#!/bin/sh

FONT_URL=${font_url:-"https://raw.githubusercontent.com/powerline/fonts/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf"}
CONFIG_URL=${config_url:-"https://raw.githubusercontent.com/rafaelmoraes/dockerfiles/master/vscode/local.conf"}
FONT_DIR=${font_dir:-"~/.local/share/fonts"}

mkdir -p "$FONT_DIR"
curl -fLo "$FONT_DIR/Roboto Mono for Powerline.ttf" "$FONT_URL"

curl -o /etc/fonts/local.conf "$CONFIG_URL"
fc-cache -vf "$FONT_DIR"
