

*  There is mainly 3 files used to setup this:

1) `Dockerfile`: 

```Dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends nginx openssl gettext-base && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /tmp/nginx.conf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
```

* We used debian fs with it's binaries and packages.
* Install nginx and openssl (the tech that implement TLS, to make the public and private keys) which establish **encryption** not **Identity verification (trust)** -> because it's self signed cert.

> TLS provide : 1) Encryption and 2) Identity verification (trust), in the case where the certs are generated on the container itself, means only the first one (Encryption) is happening and not the identity turst.


* Copying nginx.conf to the container and also the script to use the openSSL and making the private, public key.


2) entrypoint.sh

```bash
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


if [ ! id nginx >/dev/null 2>&1 ]; then 
	groupadd -r nginx
	useradd -r -g nginx nginx 
fi

# Nginx can't read env variables directly
# Substitue {DOMAIN NAME} Before starting nginx.conf
envsubst '${DOMAIN_NAME}' < /tmp/nginx.conf  > /etc/nginx/nginx.conf
exec nginx -g "daemon off;"
```


3) Nginx.conf

> Each line explained with a comment above it
```conf
#run processes as nginx system user and not root privileges 
user nginx; 

# Spawns one worker process per available CPU core.
worker_processes auto; 

events {
# Max simultaneous connections each worker can hold open at once.
	worker_connections 1024; 
}

# Used to handle the `http/https`
http{
  
  # maps static files (.css, .html) into text/css so responses carry correct header 
	include /etc/nginx/mime.types; 
	# This only for static files not .php type 
	default_type application/octet-stream;
	
	# Defines one virtual host, one website domain, which handles requests matching the `listen`/`server_name` below.
	server {

		#Accepts incoming connections on port 443, treating them as TLS
		listen 443 ssl;
		# Domain name
		server_name ${DOMAIN_NAME};
		# public key
		ssl_certificate /etc/nginx/ssl/public.pem;
		# private key
		ssl_certificate_key /etc/nginx/ssl/private.pem;
		# SSL protocol used 
		ssl_protocols TLSv1.2 TLSv1.3;

		# Resolve requests from this path, must match the shared volume mount path
		root /var/www/html;
		# Default file to show in any directory requested (file not specified)
		index index.php;

# Default file to serve when a request resolves to a real directory rather than a specific file.
#Catch-all block
		location / {
			# $uri -> nginx varible of what client searched for 
			try_files $uri $uri/ /index.php?$args;
		}
		location ~ \.php$ {
		# Make sure the file exists or give 404
			try_files $uri =404;
			
		# Loads standard FastCGI parameters (query string, request method, headers, etc.) needed by PHP-FPM.
			include /etc/nginx/fastcgi_params;
			
# Making my own parameter, document_root -> /var/www/html, fastcgi_sc...-> $uri
# telling PHP-FPM the absolute filesystem path of the script to execute, e.g. `/var/www/html/wp-login.php`.			
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			
			#Forwards the request over the Docker network, using the FastCGI protocol, to PHP-FPM listening on port 9000 inside the `wordpress` container. nginx never executes PHP itself — this line hands the request off entirely.
			fastcgi_pass wordpress:9000;
		}

	}
}
```


Here's the condensed reference, the core building blocks you've actually used, stripped to essentials.

**Structure blocks**

- `events { }` — connection handling settings (mandatory)
- `http { }` — everything web-related lives here
- `server { }` — one virtual host (domain + port combo)
- `location { }` — routing rules for specific URI patterns

**Global settings**

- `user` — Linux user worker processes run as
- `worker_processes` — how many worker processes to spawn
- `worker_connections` — max simultaneous connections per worker

**Server identity**

- `listen` — which port to accept connections on
- `server_name` — which `Host` header this block responds to

**TLS/SSL**

- `ssl_certificate` / `ssl_certificate_key` — cert and key file paths
- `ssl_protocols` — which TLS versions to accept

**File resolution**

- `root` — base directory for resolving request paths to disk files
- `index` — default filename when a request resolves to a directory
- `try_files` — try candidates in order, serve first match, fallback to last

**MIME/content typing**

- `include mime.types` — extension → Content-Type mapping
- `default_type` — fallback Content-Type when extension isn't recognized

**Proxying to PHP-FPM (FastCGI)**

- `fastcgi_pass` — where to forward `.php` requests (host:port)
- `fastcgi_param` — key-value parameters sent to PHP-FPM (e.g. `SCRIPT_FILENAME`)
- `include fastcgi_params` — loads the standard set of FastCGI parameters

**Modularity**

- `include` — pulls another config file's contents in at that point (used for `mime.types`, `fastcgi_params`, or splitting `server{}` blocks into separate files)

