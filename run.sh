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

# --- sysbox requirement check -------------------------------------------------

# Workspace tutorial requires sysbox due to CSI driver mount propagation requirements
(
  if [ "$TUTORIAL" = "workspace" ]; then
    if [ -f "${LOCALCODA_ROOT}/backend/cfg/conf" ]; then
      source "${LOCALCODA_ROOT}/backend/cfg/conf"
    fi

    if [ "$VIRT_ENGINE" != "sysbox" ]; then
      echo "ERROR: The workspace tutorial requires sysbox virtualisation engine."
      echo ""
      echo "The CSI-rclone plugin used by the Workspace building block requires"
      echo "mount propagation features that are only available with sysbox."
      echo ""
      echo ""
      echo "See: https://github.com/EOEPCA/eoepca-killercoda#running-on-localcoda"
      exit 1
    fi
  fi
) || exit $?

# --- run logic ----------------------------------------------------------------
BACKEND_OPTS=""
if [ -n "$EXT_DOMAIN_NAME" ]; then
  BACKEND_OPTS="-o EXT_DOMAIN_NAME=${EXT_DOMAIN_NAME}"
fi

"${LOCALCODA_ROOT}"/backend/bin/backend_run.sh $BACKEND_OPTS "${BIN_DIR}" "${TUTORIAL}/index.json"
