#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

function onExit() {
  cd "${ORIG_DIR}"
}
trap "onExit" EXIT

if [ -f .envrc ] ; then source .envrc; fi

if [ -z "$LOCALCODA_ROOT" ]; then
  echo "ERROR: LOCALCODA_ROOT is not set"
  exit 1
fi

TUTORIAL="${1:-${TUTORIAL}}"
if [ -z "$TUTORIAL" ]; then
  echo "ERROR: TUTORIAL is not set"
  exit 1
fi

stop_tutorial() {
  local id="$1"
  "${LOCALCODA_ROOT}"/backend/bin/backend_stop.sh "$id"
}

matched=0
while read -r id name; do
  if [ "$TUTORIAL" = "all" ] || [ "$TUTORIAL" = "$name" ]; then
    echo "Stopping tutorial: $name (ID: $id)"
    stop_tutorial "$id"
    matched=$((matched + 1))
  fi
done < <(./list.sh)

if [ "$matched" -eq 0 ]; then
  if [ "$TUTORIAL" == "all" ]; then
    echo "No running tutorials found."
  else
    echo "No running tutorial: $TUTORIAL" >&2
  fi
  exit 1
else
  echo "Stopped $matched tutorial(s)."
fi
