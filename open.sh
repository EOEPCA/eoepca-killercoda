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

# --- extract access_url using the ID -----------------------------------------

ACCESS_URL="$(
  "${LOCALCODA_ROOT}"/backend/bin/backend_ls.sh \
    | jq -r --arg id "$TUTORIAL_ID" '
        .[] | select(.id == $id) | .access_url
      '
)"

if [ -z "$ACCESS_URL" ] || [ "$ACCESS_URL" = "null" ]; then
  echo "ERROR: Could not determine access_url for tutorial '$TUTORIAL'" >&2
  exit 1
fi

# --- open tutorial ------------------------------------------------------------

echo "Opening tutorial '$TUTORIAL' at:"
echo "  $ACCESS_URL"

xdg-open "$ACCESS_URL" >/dev/null 2>&1 &

echo "Browser launched."
