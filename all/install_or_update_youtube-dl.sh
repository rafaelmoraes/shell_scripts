#!/bin/sh
# Script to install or update youtube-dl
if [ -x "$(which curl)" ]; then
  sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
else
  sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl
fi

sudo chmod a+rx /usr/local/bin/youtube-dl
