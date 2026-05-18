#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: toggle_mode.command debug|dev|prod
EOF
  exit 1
}

if (( $# != 1 )); then
  usage
fi

case "$1" in
  debug)
    mode="debug"
    scale="adaptive"
    ;;
  dev)
    mode="development"
    scale="adaptive"
    ;;
  prod)
    mode="production"
    scale="letterbox"
    ;;
  *)
    usage
    ;;
esac

main_file="Solar2D/main.lua"
config_file="Solar2D/config.lua"

mode_count="$(grep -cE '^[[:space:]]*env\.mode[[:space:]]*=' "$main_file")"
if [[ "$mode_count" -ne 1 ]]; then
  printf 'env.mode assignment not found or ambiguous (found %s)\n' "$mode_count" >&2
  exit 1
fi

sed -i '' -E "s/^([[:space:]]*env\.mode[[:space:]]*=[[:space:]]*)\"[^\"]*\"/\1\"$mode\"/" "$main_file"

scale_count="$(grep -cE '^[[:space:]]*scale[[:space:]]*=' "$config_file")"
if [[ "$scale_count" -ne 1 ]]; then
  printf 'scale assignment not found or ambiguous (found %s)\n' "$scale_count" >&2
  exit 1
fi

sed -i '' -E "s/^([[:space:]]*scale[[:space:]]*=[[:space:]]*)\"[^\"]*\"(,?)/\1\"$scale\"\2/" "$config_file"

printf 'Set env.mode=%s and scale=%s\n' "$mode" "$scale"