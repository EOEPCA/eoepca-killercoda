#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/../../commons/intro_background.sh"

# The Application Quality ingress is created for the tutorial's public host name, so the proxy has
# to present that name to the cluster rather than the in-cluster name it forwards to.
AQ_PROXY_PORT="$(awk '$2 == "application-quality.eoepca.local" {print $1}' /tmp/assets/killercodaproxy)"
AQ_PUBLIC_HOST="$(sed "s/PORT/${AQ_PROXY_PORT}/" /etc/killercoda/host | sed -E 's#^https?://##')"
sed -i "s/proxy_set_header Host application-quality.eoepca.local;/proxy_set_header Host ${AQ_PUBLIC_HOST};/" /etc/nginx/nginx.conf
nginx -s reload
