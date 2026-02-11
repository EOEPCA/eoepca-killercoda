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

# --- argument handling + inference -------------------------------------------

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
      # Exactly one running → infer it
      read -r id TUTORIAL <<< "${lines[0]}"
      ;;
    *)
      echo "ERROR: No tutorial specified and ${#lines[@]} tutorials are running; cannot infer" >&2
      exit 1
      ;;
  esac
fi

# --- stop function ------------------------------------------------------------

stop_tutorial() {
  local id="$1"
  "${LOCALCODA_ROOT}"/backend/bin/backend_stop.sh "$id"
}

# --- main stopping logic ------------------------------------------------------

matched=0

while read -r id name; do
  if [[ "$TUTORIAL" == "all" || "$TUTORIAL" == "$name" ]]; then
    echo "Stopping tutorial: $name (ID: $id)"
    stop_tutorial "$id"
    matched=$((matched + 1))
  fi
done < <(./list.sh)

# --- result reporting ---------------------------------------------------------

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
