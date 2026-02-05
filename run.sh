#!/usr/bin/env bash

# --- directory setup ----------------------------------------------------------

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

function onExit() {
  cd "${ORIG_DIR}"
}
trap "onExit" EXIT

# --- environment setup --------------------------------------------------------

if [ -f .envrc ] ; then source .envrc; fi

if [ -z "$LOCALCODA_ROOT" ]; then
  echo "ERROR: LOCALCODA_ROOT is not set"
  exit 1
fi

# --- argument handling --------------------------------------------------------

TUTORIAL="${1:-${TUTORIAL}}"

if [ -z "$TUTORIAL" ]; then
  echo "ERROR: TUTORIAL is not set"
  exit 1
fi

# --- run logic ----------------------------------------------------------------
BACKEND_OPTS=""
if [ -n "$EXT_DOMAIN_NAME" ]; then
  BACKEND_OPTS="-o EXT_DOMAIN_NAME=${EXT_DOMAIN_NAME}"
fi

"${LOCALCODA_ROOT}"/backend/bin/backend_run.sh $BACKEND_OPTS "${BIN_DIR}" "${TUTORIAL}/index.json"
