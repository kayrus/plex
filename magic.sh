#!/bin/bash
# This script disables transcode for videos which already have aac audio

magic=0
i=0
input=false
for arg in "$@"; do
    ((i++))
    next=$((i+1))
    if [[ "$arg" == "-i" ]]; then
      input=true
    fi
    if [[ "$arg" =~ -codec:[0-9] && "${@:$next:1}" == "aac" && $magic == 0 && $input == false ]]; then
      ((magic++))
      continue
    fi
    if [[ "$arg" == "aac" && $magic == 1 ]]; then
      ((magic++))
      continue
    fi
    if [[ "$arg" == "-codec:1" && $magic == 2 ]]; then
      ((magic++))
    fi
    if [[ "$arg" == "aac" && $magic == 3 ]]; then
      args[$i]="copy"
      ((magic++))
      continue 
    fi
    if [[ "$arg" == "-ar:1" && $magic == 4 ]]; then
      args[$i]="-copypriorss:1"
      ((magic++))
      continue 
    fi
    if [[ "$arg" == "48000" && $magic == 5 ]]; then
      args[$i]="0"
      ((magic++))
      continue 
    fi
    if [[ "$arg" == "-channel_layout:1" && $magic == 6 ]]; then
      ((magic++))
      continue 
    fi
    if [[ "$arg" == "stereo" && $magic == 7 ]]; then
      ((magic++))
      continue 
    fi
    if [[ "$arg" == "-b:1" && $magic == 8 ]]; then
      ((magic++))
      continue 
    fi
    if [[ "$arg" == "256k" && $magic == 9 ]]; then
      ((magic++))
      continue 
    fi
    args[$i]=$(printf "%q" "$arg")
done
set -- "${args[@]}"
eval "/opt/plex/Application/Resources/Plex\ Transcoder_ $@"
