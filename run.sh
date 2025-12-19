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

"${LOCALCODA_ROOT}"/backend/bin/backend_run.sh $PWD "${TUTORIAL}"/index.json
