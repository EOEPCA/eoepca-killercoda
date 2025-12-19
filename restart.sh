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
      # Exactly one running → infer it
      read -r id TUTORIAL <<< "${lines[0]}"
      ;;
    *)
      echo "ERROR: No tutorial specified and ${#lines[@]} tutorials are running; cannot infer" >&2
      exit 1
      ;;
  esac
fi

# --- verify that the specified tutorial is running ----------------------------

mapfile -t running < <(./list.sh | awk '{print $2}')

if [[ ! " ${running[*]} " =~ " ${TUTORIAL} " ]]; then
  echo "ERROR: Tutorial '$TUTORIAL' is not running" >&2
  exit 1
fi

# --- restart logic ------------------------------------------------------------

echo "Restarting tutorial: ${TUTORIAL}..."

./stop.sh "$TUTORIAL"
./run.sh "$TUTORIAL"

echo "...Restarted tutorial: $TUTORIAL"
