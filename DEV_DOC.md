# Developer Documentation

This document explains how to set up, build, and maintain the Inception stack from a developer's perspective.

## Prerequisites

- A Linux virtual machine (the subject requires this activity to run inside a VM, not directly on host hardware).
- Docker Engine and the Docker Compose plugin installed.
- `make`.

## Repository layout

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                    # gitignored — one password per file
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env                    # gitignored — non-sensitive config
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf          (template, uses ${DOMAIN_NAME})
        │   └── tools/entrypoint.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf            (PHP-FPM pool config)
        │   └── tools/entrypoint.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/my.cnf              (bind-address override)
            └── tools/entrypoint.sh
```

## Setting up the environment from scratch

### 1. Configuration file (`srcs/.env`)

```bash
DOMAIN_NAME=<login>.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
WP_ADMIN_USER=<non-admin-sounding-username>
WP_ADMIN_EMAIL=admin@<login>.42.fr
WP_USER=<second-username>
WP_USER_EMAIL=editor@<login>.42.fr
DATA_PATH=/home/<login>/data
```

`WP_ADMIN_USER` must not contain `admin` or `administrator` in any casing — this is enforced by the subject, not by the scripts.

### 2. Secrets (`secrets/`)

Each file holds a single plaintext password, no trailing content beyond the password itself:

```bash
mkdir -p secrets
echo "<strong-password>" > secrets/db_password.txt
echo "<strong-password>" > secrets/db_root_password.txt
echo "<strong-password>" > secrets/wp_admin_password.txt
echo "<strong-password>" > secrets/wp_user_password.txt
```

Both `srcs/.env` and `secrets/` are listed in `.gitignore` and must never be committed.

### 3. Local DNS

```bash
echo "127.0.0.1  <login>.42.fr" | sudo tee -a /etc/hosts
```

## Building and launching

```bash
make            # build + start everything (equivalent to `make up`)
```

Under the hood this runs:
```bash
docker compose -f srcs/docker-compose.yml up --build -d
```
after first creating the host-side data directories at `$DATA_PATH/wordpress` and `$DATA_PATH/mariadb` (read from `.env`).

Other targets:

```bash
make down      # stop + remove containers, keep volumes
make stop      # pause containers
make start     # resume containers
make clean     # down + prune unused Docker resources
make fclean    # clean + wipe persisted volume data
make re        # fclean + all — full rebuild from a clean slate
```

## Managing containers and volumes

Standard Compose commands, scoped to `srcs/docker-compose.yml`:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f <service>
docker compose -f srcs/docker-compose.yml exec <service> sh
```

To inspect the database directly:
```bash
docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u root -p
```

To run WP-CLI commands against the live WordPress install:
```bash
docker compose -f srcs/docker-compose.yml exec wordpress \
  wp <command> --allow-root --path=/var/www/html
```

## Where data is stored and how it persists

Two Docker **named volumes** back the persistent state, each configured with `driver_opts` to bind their storage to a specific host path (satisfying the subject's requirement that data live under `/home/<login>/data` while still being managed as named volumes rather than raw bind mounts):

| Volume | Container path | Host path |
|---|---|---|
| `wordpress_data` | `/var/www/html` (mounted in both `nginx` and `wordpress`) | `$DATA_PATH/wordpress` |
| `db_data` | `/var/lib/mysql` (mounted in `mariadb`) | `$DATA_PATH/mariadb` |

`wordpress_data` is shared between the `nginx` and `wordpress` containers at the same path, which is what lets NGINX serve static files and verify `.php` file existence without needing a copy of WordPress's files inside its own image.

Each entrypoint script is idempotent: it checks for markers of prior setup (e.g. `wp-config.php` existing, or `/var/lib/mysql/mysql` existing) before running first-time initialization, so restarting a container with existing volume data does not re-run setup or overwrite existing content.

## First-time setup sequence (for reference when debugging)

**MariaDB**: on an empty volume, initializes the data directory (`mariadb-install-db`), starts a temporary background instance, waits for it to accept connections, runs one-time SQL (`ALTER USER` for root, `CREATE DATABASE`, `CREATE USER` + `GRANT` for the WordPress database user), then shuts the temporary instance down before starting the real, foreground instance.

**WordPress**: waits for MariaDB to report healthy (via Compose's `depends_on: condition: service_healthy`), downloads WordPress core files if absent, generates `wp-config.php` from `.env`/secrets if absent, runs `wp core install` if not already installed (creating the admin user), creates the second user if absent, fixes file ownership to `www-data`, then starts PHP-FPM in the foreground.

**NGINX**: generates a self-signed TLS certificate if absent, substitutes `${DOMAIN_NAME}` into the NGINX config template via `envsubst`, then starts NGINX in the foreground.
