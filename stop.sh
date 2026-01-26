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

# --- cleanup ------------------------------------------------------------------

clean_mounts() {
  local id="$1" prefix="" _prefix m

  if [[ -z "$id" ]]; then
    echo "ERROR: clean_mounts requires an ID" >&2
    return 1
  fi

  while IFS= read -r m; do
    echo "Unmounting: $m"
    sudo umount -l "$m"

    _prefix="${m%%/$id/*}"

    if [[ -z "$prefix" ]]; then
      prefix="$_prefix"
    elif [[ "$_prefix" != "$prefix" ]]; then
      echo "ERROR: multiple mount prefixes detected: $prefix and $_prefix" >&2
      return 2
    fi

  done < <(mount | awk -v t="$id" '$3 ~ ("^.*/" t "/.*$") {print $3}')

  if [[ -z "$prefix" ]]; then
    echo "No mountpoints found for ID: $id" >&2
    return 3
  fi

  if [[ ! -d "$prefix/$id" ]]; then
    echo "ERROR: expected directory does not exist: $prefix/$id" >&2
    return 4
  fi

  echo "Removing shared kubelet mounts at: $prefix/$id"
  sudo rm -rf "$prefix/$id"
}

# --- main stopping logic ------------------------------------------------------

matched=0

while read -r id name; do
  if [[ "$TUTORIAL" == "all" || "$TUTORIAL" == "$name" ]]; then
    echo "Stopping tutorial: $name (ID: $id)"
    stop_tutorial "$id"
    clean_mounts "$id"
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
