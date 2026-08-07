#!/bin/bash

# IF anything failed, non-zero exit code
set -e 

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/public.pem ]; then
	# -nodes: TO avoid entring password for private key
	    # -subj avoids interactive prompts for identity fields
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/private.pem \
        -out /etc/nginx/ssl/public.pem \
        -subj "/C=JO/ST=Amman/L=Amman/O=42/OU=42/CN=${DOMAIN_NAME}"

fi



# Nginx can't read env variables directly
# Substitue {DOMAIN NAME} Before starting nginx.conf
envsubst '${DOMAIN_NAME}' < /tmp/nginx.conf  > /etc/nginx/nginx.conf
exec nginx -g "daemon off;"

