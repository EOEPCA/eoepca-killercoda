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

# If no tutorial provided, infer from running list
if [ -z "$TUTORIAL" ]; then
  mapfile -t lines < <(./list.sh)

  case "${#lines[@]}" in
    0)
      echo "ERROR: No tutorials are currently running" >&2
      exit 1
      ;;
    1)
      read -r id TUTORIAL <<< "${lines[0]}"
      ;;
    *)
      echo "ERROR: No tutorial specified and ${#lines[@]} tutorials are running; cannot infer" >&2
      exit 1
      ;;
  esac
fi

# --- verify that the specified tutorial is running ----------------------------

# Extract the ID for the selected tutorial
TUTORIAL_ID="$(
  ./list.sh | awk -v t="$TUTORIAL" '$2 == t { print $1 }'
)"

if [ -z "$TUTORIAL_ID" ]; then
  echo "ERROR: Tutorial '$TUTORIAL' is not running" >&2
  exit 1
fi

# --- extract container name using the ID -----------------------------------------

CONTAINER_NAME="$(
  "${LOCALCODA_ROOT}"/backend/bin/backend_ls.sh \
    | jq -r --arg id "$TUTORIAL_ID" '
        .[] | select(.id == $id) | .instance_name
      '
)"

if [ -z "$CONTAINER_NAME" ] || [ "$CONTAINER_NAME" = "null" ]; then
  echo "ERROR: Could not determine container name for tutorial '$TUTORIAL'" >&2
  exit 1
fi

# --- open console ------------------------------------------------------------

echo "Opening console for tutorial '$TUTORIAL'"

docker exec -it "$CONTAINER_NAME" bash
