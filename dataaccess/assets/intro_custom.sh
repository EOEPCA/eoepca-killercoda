#!/bin/bash

HTTP_PORT=99
echo "setting up HTTP server on port ${HTTP_PORT}..." >> /tmp/killercoda_setup.log
cat <<EOF > /etc/nginx/conf.d/default.conf
    server {
        listen ${HTTP_PORT};

        location / {
            root /var/www/html;
        }
    }
EOF

echo "installing extra tools..." >> /tmp/killercoda_setup.log
[[ -e /tmp/apt-is-updated ]] || { apt-get update -y; touch /tmp/apt-is-updated; }
apt install -y file dos2unix jq gdal-bin gettext-base
