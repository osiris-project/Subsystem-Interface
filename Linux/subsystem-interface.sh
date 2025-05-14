#!/bin/sh
echo -ne '\033c\033]0;Subystem Interface\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/subsystem-interface.x86_64" "$@"
