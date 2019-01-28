#!/bin/bash
##############################################################################
# install_and_configure_i3_or_openbox_environment.sh
# -----------
# This script install and configure I3 or Openbox or both with complete environment
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-01-25
# :VERSION: 0.0.1
##############################################################################
set -euo pipefail
# HELPERS
i_echo() { echo "[INFO] - $1"; }
w_echo() { echo "[WARN] - $1"; }
e_echo() { echo "[ERROR] - $1"; }
exit_is_not_superuser() {
    if [ "$(id -u)" != "0" ]; then w_echo "Run as root or using sudo."; exit 1; fi
}
# VARIABLES
USER_NAME=${SUDO_USER:-$USER}
TMP_DIR="/tmp/environment-installation-$(date +%s)"
URL_SRC_BASE='https://raw.githubusercontent.com/rafaelmoraes/shell_scripts/master'
URL_SRC_ALL="$URL_SRC_BASE/all"
URL_SRC_DEBIAN="$URL_SRC_BASE/debian"

OPENBOX=false
I3=false
HELP_MESSAGE="Usage: ./install_and_configure_i3_or_openbox_environment.sh [OPTIONS]

Parameters list
  -u, --user=   Set the owner of the installation (default: $USER_NAME)
  --openbox     Install the Openbox Window Manager (default: disabled)
  --i3          Install the I3 Window Manager (default: enabled)
  -h, --help    Show usage"

# Read user parameters
apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u) USER_NAME="$2"; shift 2;;
            --user=*) USER_NAME="${1#*=}"; shift 1;;

            --openbox) OPENBOX=true; shift 1;;
            --i3) I3=true; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *) echo "Unknown option: $1" >&2; exit 1;;
        esac
    done
}

##### SECTION - INSTALLATION #####
show_warning_when_user_root() {
    if [ "$USER_NAME" == 'root' ]; then
        w_echo 'The user of the installation is root.'
        echo 'Are you sure you want continue installation? (y|n)'
        read -r answer
        case $answer in
            y|Y|s|S)
                i_echo 'Continuing installation as root.';;
            *)
                e_echo 'Instalation aborted.'; exit 1;;
        esac
    fi
}

create_temporary_directory() {
    i_echo "Create installation temporary directory"
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"
}

include_non_free_sources() {
    i_echo "Add non free repository on sources.list"
    sed 's| main$| main contrib non-free|' \
        -i /etc/apt/sources.list && apt update
}

install_pre_requirements() {
    apt install -y \
		        apt-transport-https \
		        ca-certificates \
		        curl \
		        dirmngr \
		        gnupg2 \
		        lsb-release \
                --no-install-recommends
}

install_audio_and_video_support() {
    i_echo "Installing audio and video support"
    apt install -y pulseaudio \
                pulseaudio-module-bluetooth \
                xorg \
                xserver-xorg \
                xserver-xorg-video-intel \
                xserver-xorg-input-libinput \
                xserver-xorg-video-vesa
}

install_window_manager_and_system_tools() {
    i_echo "Installing window manager dependencies"
    apt install -y slim \
                   arandr \
                   dunst \
                   i3lock

    if [[ "$I3" == true || "$OPENBOX" == "$I3" ]]; then
        i_echo "Installing I3"
        apt install -y i3 
    fi

    if [ "$OPENBOX" == true ]; then
        i_echo "Installing Openbox"
        apt install -y openbox \
                       obmenu \
                       tint2 \
                       lxappearance-obconf
    fi
}

install_command_line_utilities() {
    apt install -y sudo \
                   vim \
                   feh \
                   scrot \
                   htop
}

install_laptop_utilities() {
    apt install -y powertop \
                libinput-tools \
                xinput \
                blueman \
                xbacklight
}

install_files_handlers() {
    i_echo "Installing files handlers"
    apt install -y thunar \
                thunar-archive-plugin \
                thunar-volman\
                thunar-media-tags-plugin\
                ntfs-3g \
                gvfs-backends \
                dirmngr \
                xarchiver \
                unrar \
                unzip \
                p7zip-full
}

install_system_tray_utilities() {
    i_echo "Installing system tray utilities"
    apt install -y clipit \
                pasystray \
                pavucontrol \
                network-manager \
                network-manager-gnome
}

install_look_and_feel() {
    i_echo "Installing look and feel tools and improviments"
    apt install -y lxappearance \
                compton \
                qt4-qtconfig \
                arc-theme \
                ttf-mscorefonts-installer
}

install_user_programs() {
    i_echo "Installing user favorite programs from official repository"
    apt install -y evince \
                xfce4-terminal \
                thunderbird \
                thunderbird-l10n-pt-br \
                uget \
                transmission-gtk \
                hexchat \
                keepassx \
                shutter \
                gimp \
                vlc \
                gparted
}

get_and_run_scripts() {
    options=""
    scripts=""
    url=""
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -o) options="$2"; shift 2;;
            --options=*) options="${1#*=}"; shift 1;;
            -u) url="$2"; shift 2;;
            --url=*) url="${1#*=}"; shift 1;;
            *) scripts="$scripts $1"; shift 1;;
        esac
    done
    for script in $scripts; do
        if [[ ! "$script" =~ +.\.sh ]]; then script="$script.sh"; fi
        wget "$url/$script"
        chmod +x "$script"
        bash -c "./$script $options"
    done
}

install_look_and_feel_external() {
    i_echo "Installing look and feel improvements from external sources"
    get_and_run_scripts -u "$URL_SRC_ALL/installers" \
                        install_flat_remix_icon_theme \
                        install_powerline_and_nerd_fonts \
                        install_san_francisco_font \
                        -o "-u $USER_NAME"

    if [ "$OPENBOX" == true ]; then
        get_and_run_scripts -u "$URL_SRC_ALL/installers" \
                            install_arc_openbox_theme
    fi
}

install_external_user_programs() {
    i_echo "Installing user favorite programs from unofficial repositories"
    get_and_run_scripts -u "$URL_SRC_DEBIAN/installers" \
                        install_ulauncher \
                        install_firefox_next \
                        install_google_chrome \
                        install_opera \
                        install_virtualbox
}

install_external_user_cli_programs() {
    i_echo "Installing user cli programs"
    get_and_run_scripts -u "$URL_SRC_ALL/installers" \
                        -o "-u $USER_NAME" \
                        install_oh_my_zsh \
                        install_or_update_youtube_dl
}

#### SECTION - CONFIGURATION

configure_sudo() {
    adduser "$USER_NAME" sudo
}

fix_intel_video_tearing() {
    get_and_run_scripts -u "$URL_SRC_ALL/configurators" fix_intel_video_tearing
}

configure_keyboard() {
   get_and_run_scripts -u "$URL_SRC_ALL/configurators" keyboard
}

configure_my_dotfiles() {
    get_and_run_scripts -u "$URL_SRC_ALL/configurators" \
                        -o "-u $USER_NAME" \
                        configure_my_dotfiles
}

clean_up() {
    rm -rf "$TMP_DIR"
}

main() {
    apply_options "$@"
    exit_is_not_superuser
    i_echo "I3 ENVIRONMENT INSTALLER"

    show_warning_when_user_root

    create_temporary_directory
    include_non_free_sources
    install_pre_requirements
    install_audio_and_video_support
    install_window_manager_and_system_tools
    install_command_line_utilities
    install_laptop_utilities
    install_files_handlers
    install_system_tray_utilities
    install_look_and_feel
    install_user_programs

    install_look_and_feel_external
    install_external_user_programs
    install_external_user_cli_programs

    configure_sudo

    fix_intel_video_tearing
    configure_keyboard
    configure_my_dotfiles
    clean_up

    i_echo "I3 ENVIRONMENT INSTALLED AND CONFIGURED SUCCESSFULLY"
    i_echo "Please reboot the system."
}

main "$@"

