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

"${LOCALCODA_ROOT}"/backend/bin/backend_ls.sh | jq -r --arg cwd "$(pwd)/" '
  .[] |
  (.tutorial_path | sub("^" + $cwd; "") | sub("/index.json$"; "")) as $name |
  "\(.id) \($name)"
'
