#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/../../commons/intro_background.sh"

if [[ -e /tmp/assets/application-quality-localcoda-proxy ]]; then
  echo "configuring Application Quality Localcoda proxy watcher..." >> /tmp/killercoda_setup.log
  (
    bash /tmp/assets/application-quality-localcoda-access proxy-watch
  ) &> /tmp/application-quality-localcoda-proxy.log &
fi
