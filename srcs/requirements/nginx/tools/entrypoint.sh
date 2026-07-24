#!/bin/bash

mkdir /etc/nginx/ssl

if [ ! /etc/nginx/ssl/fullchain.pem ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		# PRivate key
        -keyout /etc/nginx/ssl/privkey.pem \
		# Public key
        -out /etc/nginx/ssl/fullchain.pem \

		# To avoid openssl to ask questions
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}"

fi


exec nginx -g "daemon off;"

