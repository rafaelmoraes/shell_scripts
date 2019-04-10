#!/bin/bash
##############################################################################
# video_reencoder.sh
# -----------
# Reencode videos using x265 through ffmpeg
#
#
# :AUTHORS: Rafael Moraes <roliveira.moraes@gmail.com>
# :DATE: 2019-04-05
# :VERSION: 0.0.1
##############################################################################

set -euo pipefail

i_echo() { echo "[INFO] - $1"; }
e_echo() { echo "[ERROR] - $1"; }

# VARIABLES
DELETE_IN=true
ALL_FILES=false
IN=""
OUT=""
CRF=25
BITS=10
HELP_MESSAGE="Usage: video_reencoder [OPTIONS]

Parameters list
  -i, --input=              Input file
  -o, --output=             Output file
  -c, --crf=                Sets CRF, increase the value increases the output file size, what usually does not mean better quality(default: $CRF)
  -b, --bits=               Sets the amount of bits to represent the video colors(default: $BITS, available: 8, 10 or 12)
  -npi, --no-delete-input   Prevents to delete the input video file after reencode
  -a, --all                 Tries to re-encode all files present at the current directory
  -h, --help    Show help."

apply_options() {
    while [ "$#" -gt 0 ]; do
        case "$1" in

            -i) IN="$2"; shift 2;;
            --input=*) IN="${1#*=}"; shift 1;;

            -o) OUT="$2"; shift 2;;
            --output=*) OUT="${1#*=}"; shift 1;;

            -c) CRF="$2"; shift 2;;
            --crf=*) CRF="${1#*=}"; shift 1;;

            -b) BITS="$2"; shift 2;;
            --bits=*) BITS="${1#*=}"; shift 1;;

            -npi|--no-delete-input) DELETE_IN=false; shift 1;;

            -a|--all) ALL_FILES=true; shift 1;;

            -h|--help) echo "$HELP_MESSAGE"; exit 0;;

            *)
                if [[ -e "$1" && -z "$IN" ]]; then
                    IN="$1"; shift 1
                elif [[ "$1" =~ \.(mp4|mkv)$ ]]; then
                    OUT="$1"; shift 1
                else
                   echo "Unknown option: $1" >&2; exit 1;
                fi
        esac
    done
}


_video_duration() {
    echo $(ffprobe "$1" 2>&1 \
                  | grep Duration \
                  | awk -F ',' '{print $1}' \
                  | awk -F ': ' '{print $2}' \
                  | awk -F '.' '{print $1}')

}

_video_resolution() {
    echo $(ffprobe \
                   -v quiet \
                   -print_format json \
                   -show_format \
                   -show_streams \
                   "$1" \
                   | grep '"height"' \
                   | awk -F ':' '{ print $2 }' \
                   | sed 's/,/p/; s/ //g')
}

_file_name() {
    file=$1
    case $2 in
        --get-extension )
            echo "$file" | awk -F '.' '{ print $NF }'
            ;;
        --remove-extension)
            ext=$(_file_name "$file" --get-extension)
            echo "${file%.$ext}"
            ;;
    esac
}

_pixel_formater(){
    case "$BITS" in
        8) echo 'yuv420p';;
        10) echo 'yuv420p10le';;
        12) echo 'yuv420p12le';;
    esac
}

_out_name() {
    if [[ -z "$OUT" && -n "$IN" ]]; then
        name=$(_file_name "$IN" --remove-extension)
        resolution=$(_video_resolution "$IN")
        extension=$(_file_name "$IN" --get-extension)

        if [[ ! "$extension" =~ 'mkv|mp4' ]]; then
            extension='mp4'
        fi
        OUT="$name [$resolution x265 ${BITS}bits].$extension"
    fi

    echo "$OUT"
}

_reencode_duration() {
    time_diff=$(($(date +%s) - $1))
    hours=$((time_diff / 3600))
    minutes=$((time_diff % 3600 / 60))
    seconds=$((time_diff % 60 ))
    if [[ $hours -lt 10 ]]; then hours="0$hours"; fi
    if [[ $minutes -lt 10 ]]; then minutes="0$minutes"; fi
    if [[ $seconds -lt 10 ]]; then seconds="0$seconds"; fi
    echo "$hours:$minutes:$seconds"
}

_is_x265() {
    ffprobe \
            -v quiet \
            -print_format json \
            -show_format \
            -show_streams \
            "$1" \
            | grep -q 'H.265'
    if [[ $? == 1 ]]; then
        echo false
    else
        echo true
    fi
}

_delete_input() {
    if [[ $DELETE_IN == true && \
        $(_video_duration "$IN") == $(_video_duration "$(_out_name)") ]]; then
        rm "$IN"
    fi
}

reencode() {
    if [[ -e "$IN" && $(_is_x265 "$IN") == false ]]; then
        reencode_start_time_in_seconds=$(date +%s)
        reencode_start_time=$(date +%T)

        ffmpeg -i "$IN" \
               -c:a aac -b:a 128k \
               -c:v libx265 \
               -preset medium \
               -crf "$CRF" \
               -pix_fmt "$(_pixel_formater)" \
               "$(_out_name)"

        _delete_input

        echo "$IN"
        i_echo "Started: $reencode_start_time"
        i_echo "Finished: $(date +%T)"
        reencode_time=$(_reencode_duration "$reencode_start_time_in_seconds")
        i_echo "Total time: $reencode_time"
        echo ""
        return 0
    else
        return 1
    fi
}

main() {
    apply_options "$@"

    if [[ $ALL_FILES == true ]]; then
        all_start_time_in_seconds=$(date +%s)
        all_start_time=$(date +%T)
        i_echo "[Multi Files]"
        i_echo "Start time: $all_start_time"

        reencode_count=0
        for file in *.{mp4,mkv,flv,wmv,avi,mov}; do
            IN=$file
            if reencode; then
               reencode_count=$((reencode_count + 1))
            fi
        done
        i_echo "[Multi Files]"
        i_echo "Total videos: $reencode_count"
        i_echo "Started: $all_start_time"
        i_echo "Finished: $(date +%T)"
        all_total_time=$(_reencode_duration "$all_start_time_in_seconds")
        i_echo "Total time: $all_total_time"
    else
        reencode
    fi
}

main "$@"
