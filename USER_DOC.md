# User Documentation

This document explains how an end user or administrator can operate the Inception stack, no development knowledge required.

## What services does the stack provide?

The project runs a small WordPress website behind an NGINX reverse proxy, backed by a MariaDB database:

| Service | Role |
|---|---|
| **NGINX** | The only entrypoint into the stack. Serves the site over HTTPS (port 443) using TLS 1.2/1.3, and forwards PHP requests to WordPress. |
| **WordPress + PHP-FPM** | The content management system that powers the actual website — blog posts, pages, media, and the admin dashboard. |
| **MariaDB** | The database that stores everything WordPress needs: posts, pages, users, and site settings. |

None of these services are reachable directly from outside, only NGINX is exposed, on port 443.

## Starting and stopping the stack

From the project root:

```bash
make          # builds and starts everything
make down     # stops and removes containers (data is kept)
make stop     # pauses containers without removing them
make start    # resumes previously stopped containers
make fclean   # stops everything AND wipes all stored data — irreversible
```

`make` (or `make up`) is the only command needed for a first-time run, it builds every image and starts all three containers automatically.

## Accessing the website and the admin panel

Before the site works in a browser, your machine needs to resolve the project's domain to your local machine. Add this line to `/etc/hosts` (as root/sudo):

```
127.0.0.1    <your-login>.42.fr
```

Once that's in place:

- **Website**: `https://<your-login>.42.fr`
- **Admin panel**: `https://<your-login>.42.fr/wp-admin/`

Your browser will warn that the certificate isn't trusted — this is expected. The site uses a self-signed TLS certificate (there is no public Certificate Authority that can issue a certificate for a `.42.fr` domain). The connection is still encrypted; only the certificate's trust chain is unverified. Accept the warning to continue.

## Locating and managing credentials

Two kinds of configuration hold credentials:

- **`srcs/.env`** — non-sensitive configuration: domain name, database name, usernames, emails.
- **`secrets/`** — passwords only, one plaintext file per secret (e.g. `secrets/wp_admin_password.txt`). This folder is excluded from version control.

There are two WordPress accounts by default:

| Role | Username source | Password source |
|---|---|---|
| Administrator | `WP_ADMIN_USER` in `.env` | `secrets/wp_admin_password.txt` |
| Editor | `WP_USER` in `.env` | `secrets/wp_user_password.txt` |

To change a password, edit the relevant file inside `secrets/` **before** the first `make up` — passwords are only applied during the database's first-time setup. Changing a secret file after the stack has already been initialized once will not retroactively change the live password (see `DEV_DOC.md` for how to update it manually if needed).

## Checking that services are running correctly

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three containers should show as `Up`, and `mariadb` should show `(healthy)`. If `wordpress` or `nginx` show as repeatedly restarting, check their logs:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

A quick manual check that the site itself is reachable:

```bash
curl -kv https://<your-login>.42.fr
```

A response with an HTML body (not a connection error or a `502`) confirms NGINX, PHP-FPM, and MariaDB are all correctly wired together.
