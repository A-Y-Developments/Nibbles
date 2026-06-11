#!/bin/zsh
set -euo pipefail
NAME="${1:?usage: sim_udid.sh <sim-name>}"
xcrun simctl list devices | grep "${NAME} (" | head -1 | grep -oE '[0-9A-F-]{36}'
